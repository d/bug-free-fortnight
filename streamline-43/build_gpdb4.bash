#!/bin/bash

set -e -u -o pipefail
set -x

_main() {
	time inject_orca
	time build_gpdb4
	time make_cluster
}

inject_orca() {
	tar xf /orca/bin_orca.tar -C /build/gpdb4/gpAux/ext/rhel5_x86_64
}

build_gpdb4() {
	: ${LD_LIBRARY_PATH:=}
	(
	pushd /build/gpdb4/gpAux
	source /opt/gcc_env.sh
	env IVY_HOME=/opt/releng/ivy_home make BLD_CC='ccache gcc' rhel5_x86_64_CXX='ccache g++' GPROOT=/build/install PARALLEL_BUILD=1 dist
	)
}

make_cluster() {
	: ${LD_LIBRARY_PATH:=}
	(
	pushd /build/gpdb4/gpAux
	source /build/install/greenplum-db-devel/greenplum_path.sh
	make -C /build/gpdb4/gpAux/gpdemo
	)
}

_main "$@"
