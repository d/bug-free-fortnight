#!/bin/bash

set -u -e -o pipefail
set -x

_main() {
	local -r prefix=/build/install

	mkdir -p /build/{install,xerces,gpos,orca}

	time build_xerces
	time build_gpos
	time build_orca

	local -r output=/orca
	time copy_output
}

build_xerces() {
	cd /build/xerces

	env CXX='ccache c++' CC='ccache cc' /workspace/gp-xerces/configure --prefix ${prefix}
	make -j32 -l8 install
}

build_gpos() {
	cd /build/gpos
	cmake -DCMAKE_INSTALL_PREFIX=${prefix} /workspace/gpos
	make -j32 -l8 install
}

build_orca() {
	cd /build/orca
	cmake -DCMAKE_INSTALL_PREFIX=${prefix} /workspace/gporca
	make -j32 -l8 install
}

copy_output() {
	tar cf ${output}/bin_orca.tar -C ${prefix} .
}

_main "$@"
