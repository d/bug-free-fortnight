#!/bin/bash

set -e -u -o pipefail
set -x

_main() {
	inject_orca
	build_gpdb4
}

inject_orca() {
	tar xf /orca/bin_orca.tar -C /build/gpdb4/gpAux/ext/rhel5_x86_64
}

build_gpdb4() {
	pushd /build/gpdb4/gpAux
	: ${LD_LIBRARY_PATH:=}
	time (
	source /opt/gcc_env.sh
	env IVY_HOME=/opt/releng/ivy_home make BLD_CC='ccache gcc' rhel5_x86_64_CXX='ccache g++' GPROOT=/build/install PARALLEL_BUILD=1 dist
	)
}

_main "$@"
