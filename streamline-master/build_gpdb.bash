#!/bin/bash

set -e -u -o pipefail
set -x
set -o posix

readonly DIR=$(dirname "$0")
# shellcheck source=guest_common.bash
source "${DIR}"/../guest_common.bash
# shellcheck source=streamline-master/guest_common.bash
source "${DIR}"/guest_common.bash

_main() {
	local prefix
	prefix=/build/install

	local build_mode
	parse_args "$@"

	mkdir -p ${prefix}
	time tar xf /orca/bin_orca.tar -C ${prefix}
	time tar xf /orca/bin_xerces.tar -C ${prefix}
	time build_gpdb ${prefix}
	time unittest
	time make_cluster ${prefix}
}

parse_args() {
	local args=("$@")
	build_mode=opt

	local opt
	local OPTIND
	while getopts :d opt "${args[@]+${args[@]}}" ; do
		case "${opt}" in
			d)
				build_mode=debug
				;;
			*)
				echo >&2 Unknown flag
				return 1
				;;
		esac
	done
}

build_unittest() {
	(
	cd /build/gpdb
	git grep -lF mock.mk | \
		xargs -n1 dirname | \
		xargs -n1 make -s -j8 -C
	)
}

unittest() {
	build_unittest
	make -s -j8 -C /build/gpdb/src/backend unittest-check
}


build_gpdb() {
	local prefix
	prefix=$1

	local -a CONFIGURE_ENV
	CONFIGURE_ENV=(
	'LD_LIBRARY_PATH=/build/install/lib'
	)

	local -a CONFIGURE_FLAGS=(
	--enable-orca
	--with-gssapi
	--enable-mapreduce
	--with-perl
	--with-libxml
	--with-python
	--disable-gpcloud
	--disable-pxf
	--enable-gpfdist
	--enable-depend
	--enable-debug
	"--prefix=${prefix}"
	"--with-includes=${prefix}/include"
	"--with-libs=${prefix}/lib"
	'CXX=ccache c++'
	'CC=ccache cc'
	)

	if [[ "${build_mode}" == debug ]]; then
		CONFIGURE_FLAGS+=(
		--enable-cassert
		'CFLAGS=-O1 -fno-omit-frame-pointer'
		'CXXFLAGS=-O1 -fno-omit-frame-pointer'
		)
	else
		CONFIGURE_FLAGS+=(
		'CFLAGS=-O3 -fno-omit-frame-pointer'
		'CXXFLAGS=-O3 -fno-omit-frame-pointer'
		)
	fi

	build_gpdb_impl "${prefix}" CONFIGURE_ENV CONFIGURE_FLAGS
}

build_gpdb_impl() {
	local prefix
	prefix=$1
	local -r configure_env_var="$2[@]"
	local -r configure_flags_var="$3[@]"

	clone_gpdb_with_submodules gpdb

	cd /build/gpdb
	env \
		"${!configure_env_var}" \
		./configure \
		"${!configure_flags_var}"
	make CXX='ccache c++' -s -j"$(nproc)" install --output-sync=target

}

default_python_home() {
	python <<-EOF
	import sys
	print(sys.prefix)
	EOF
}

make_cluster() {
	local prefix
	prefix=$1
	: "${LD_LIBRARY_PATH:=}"
	: "${PYTHONHOME:=$(default_python_home)}"
	# poor man's ssh-keyscan
	ssh -o StrictHostKeyChecking=no $(hostname) uname
	(
	set_user_env
	# shellcheck disable=SC1090
	source "${prefix}"/greenplum_path.sh
	env BLDWRAP_POSTGRES_CONF_ADDONS='fsync=off statement_mem=250MB' make -C /build/gpdb/gpAux/gpdemo DEFAULT_QD_MAX_CONNECT=150
	)
}

_main "$@"
