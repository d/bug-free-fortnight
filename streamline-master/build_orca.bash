#!/bin/bash

set -e -u -o pipefail
set -x

readonly DIR=$(dirname "$0")
# shellcheck source=guest_common.bash
source "${DIR}"/../guest_common.bash

_main() {
	local -r prefix=/build/install
	local -r xerces_prefix=/build/install.xerces

	mkdir -p ${xerces_prefix}
	mkdir -p /build/src
	mkdir -p /build/{install,xerces,gpos,orca}

	local -i NPROC=$(( 3 * $(ncpu) / 2))
	local -i MAX_LOAD=$(( 2 * $(ncpu) ))
	time build_xerces
	time build_fat_orca

	local -r output=/orca
	time copy_output
}

build_fat_orca() {
	if build_orca; then
		true
	else
		build_gpos
		build_orca
	fi
}

build_xerces() {
	local -r host_src=/workspace/gp-xerces
	local -r src=/build/src/gp-xerces
	git clone --shared ${host_src} ${src}
	cd /build/xerces

	env CXX='ccache c++' CC='ccache gcc' ${src}/configure --prefix ${xerces_prefix}
	make -j${NPROC} -l${MAX_LOAD} install
}

build_gpos() {
	git clone --shared /workspace/gpos /build/src/gpos
	cd /build/gpos
	cmake -DCMAKE_INSTALL_PREFIX=${prefix} /build/src/gpos
	cmake --build . --target install -- -j${NPROC} -l${MAX_LOAD}
}

build_orca() {
	local -r host_src=/workspace/gporca
	local -r src=/build/src/orca
	local -r build=/build/orca
	git clone --shared ${host_src} ${src}
	cmake -GNinja -DCMAKE_PREFIX_PATH=${xerces_prefix} -DCMAKE_INSTALL_PREFIX=${prefix} -H${src} -B${build}
	cmake --build ${build} --target install -- -j${NPROC} -l${MAX_LOAD}
}

copy_output() {
	tar cf ${output}/bin_xerces.tar -C ${xerces_prefix} .
	tar cf ${output}/bin_orca.tar -C ${prefix} .
}

_main "$@"
