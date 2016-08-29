#!/bin/bash

set -u -e -o pipefail
set -x

_main() {
	local prefix
	prefix=/build/install

	mkdir -p ${prefix}
	time tar xf /orca/bin_orca.tar -C ${prefix}
	time build_the_universe ${prefix}
	time make_cluster ${prefix}
}

build_the_universe() {
	local prefix
	prefix=$1

	cd /build
	git clone --shared /workspace/gpdb
	cd gpdb
	env CXX='ccache c++' CC='ccache cc' ./configure --enable-orca --enable-mapreduce --with-perl --with-libxml --with-python --disable-gpfdist --prefix=${prefix} --with-includes=${prefix}/include --with-libs=${prefix}/lib
	make -j$(nproc) install
}

make_cluster() {
	local prefix
	prefix=$1
	set +u
	cd /build/gpdb/gpAux/gpdemo
	source ${prefix}/greenplum_path.sh
	make cluster
}

_main "$@"
