#!/bin/bash

set -u -e -o pipefail
set -x

_main() {
	local prefix
	prefix=/build/install

	mkdir -p ${prefix}
	time tar xf /orca/bin_orca.tar -C ${prefix}
	time tar xf /orca/bin_xerces.tar -C ${prefix}
	time build_gpdb ${prefix}
	# time make_cluster ${prefix}

	sudo cp --preserve=mode /workspace/bug-free-fortnight/streamline-master/compose-master-entry-point.bash /
}

build_gpdb() {
	local prefix
	prefix=$1

	cd /build
	if [[ ! -e /build/gpdb ]]; then
		git clone --shared /workspace/gpdb
	fi
	pushd gpdb
	env \
		CXX='ccache c++' \
		CC='ccache cc' \
		./configure --enable-orca --enable-mapreduce --with-perl --with-libxml --with-python --enable-gpfdist --prefix="${prefix}" --with-includes="${prefix}"/include --with-libs="${prefix}"/lib
	make CXX='ccache c++' -j"$(nproc)" install

	popd
	rm -r /build/gpdb
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
	cd /build/gpdb/gpAux/gpdemo
	# shellcheck disable=SC1090
	source "${prefix}"/greenplum_path.sh
	make cluster
}

_main "$@"
