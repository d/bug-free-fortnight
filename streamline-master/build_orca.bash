#!/bin/bash

set -u -e -o pipefail
set -x

_main() {
	local -r prefix=/build/install
	local -r xerces_prefix=/build/install.xerces

	mkdir -p ${xerces_prefix}
	mkdir -p /build/{install,xerces,gpos,orca}

	time build_xerces
	time build_gpos
	time build_orca

	local -r output=/orca
	time copy_output
}

build_xerces() {
	cd /build/xerces

	env CXX='ccache c++' CC='ccache gcc' /workspace/gp-xerces/configure --prefix ${xerces_prefix}
	make -j16 -l16 install
}

build_gpos() {
	cd /build/gpos
	cmake -DCMAKE_INSTALL_PREFIX=${prefix} /workspace/gpos
	make -j16 -l16 install
}

build_orca() {
	cd /build/orca
	cmake -DCMAKE_PREFIX_PATH=${xerces_prefix} -DCMAKE_INSTALL_PREFIX=${prefix} /workspace/gporca
	make -j16 -l16 install
}

copy_output() {
	tar cf ${output}/bin_xerces.tar -C ${xerces_prefix} .
	tar cf ${output}/bin_orca.tar -C ${prefix} .
}

_main "$@"
