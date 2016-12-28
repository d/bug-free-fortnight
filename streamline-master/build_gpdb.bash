#!/bin/bash

set -u -e -o pipefail
set -x
set -o posix

_main() {
	local prefix
	prefix=/build/install

	mkdir -p ${prefix}
	time tar xf /orca/bin_orca.tar -C ${prefix}
	time tar xf /orca/bin_xerces.tar -C ${prefix}
	time build_gpdb ${prefix}
	time make_cluster ${prefix}
}

build_gpdb() {
	local prefix
	prefix=$1

	local -a CONFIGURE_ENV
	CONFIGURE_ENV=(
	CXX='ccache c++'
	CC='ccache cc'
	)

	local -a CONFIGURE_FLAGS=(
	--enable-orca
	--enable-mapreduce
	--with-perl
	--with-libxml
	--with-python
	--enable-gpfdist
	--prefix="${prefix}"
	--with-includes="${prefix}/include"
	--with-libs="${prefix}/lib"
	)

	build_gpdb_impl "${prefix}" CONFIGURE_ENV CONFIGURE_FLAGS
}

build_gpdb_impl() {
	local prefix
	prefix=$1
	local -r configure_env_var="$2[@]"
	local -r configure_flags_var="$3[@]"

	cd /build
	if [[ ! -e /build/gpdb ]]; then
		git clone --shared /workspace/gpdb
	fi
	local -ra CONFIGURE_ENV=("${!configure_env_var}")
	local -ra CONFIGURE_FLAGS=("${!configure_flags_var}")

	cd gpdb
	env \
		"${CONFIGURE_ENV[@]}" \
		./configure \
		"${CONFIGURE_FLAGS[@]}"
	make CXX='ccache c++' -j"$(nproc)" install

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
	# shellcheck disable=SC1090
	source "${prefix}"/greenplum_path.sh
	env BLDWRAP_POSTGRES_CONF_ADDONS='fsync=off' make -C /build/gpdb/gpAux/gpdemo
	)
}

_main "$@"
