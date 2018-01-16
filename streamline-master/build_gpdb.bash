#!/bin/bash

set -e -u -o pipefail
set -x
set -o posix

# shellcheck source=guest_common.bash
source $(dirname $0)/../guest_common.bash
# shellcheck source=streamline-master/guest_common.bash
source $(dirname $0)/guest_common.bash

_main() {
	local prefix
	prefix=/build/install

	local build_mode
	parse_args "$@"

	mkdir -p ${prefix}
	time tar xf /orca/bin_orca.tar -C ${prefix}
	time tar xf /orca/bin_xerces.tar -C ${prefix}
	time build_gpdb ${prefix}
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

build_gpdb() {
	local prefix
	prefix=$1

	local -a CONFIGURE_ENV
	CONFIGURE_ENV=(
	'LD_LIBRARY_PATH=/build/install/lib'
	'CXX=ccache c++'
	'CC=ccache cc'
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
	"--prefix=${prefix}"
	"--with-includes=${prefix}/include"
	"--with-libs=${prefix}/lib"
	)

	if [[ "${build_mode}" == debug ]]; then
		CONFIGURE_ENV+=(
		'CFLAGS=-O1 -fno-omit-frame-pointer'
		)
		CONFIGURE_FLAGS+=(
		--enable-debug
		--enable-cassert
		)
	fi

	build_gpdb_impl "${prefix}" CONFIGURE_ENV CONFIGURE_FLAGS
}

build_gpdb_impl() {
	local prefix
	prefix=$1
	local -r configure_env_var="$2[@]"
	local -r configure_flags_var="$3[@]"

	clone_gpdb gpdb

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
	(
	set_user_env
	# shellcheck disable=SC1090
	source "${prefix}"/greenplum_path.sh
	env BLDWRAP_POSTGRES_CONF_ADDONS='fsync=off' make -C /build/gpdb/gpAux/gpdemo
	)
}

_main "$@"
