#!/bin/bash

set -e -u -o pipefail
set -x
set -o posix

# shellcheck source=streamline-43/guest_common.bash
source $(dirname $0)/guest_common.bash

_main() {
	time inject_orca
	time build_gpdb4
	time make_cluster
}

inject_orca() {
	local ext_dir
	readonly ext_dir=$(ext_path)

	tar xf /orca/bin_orca.tar -C "${ext_dir}"
}

build_gpdb4() {
	: "${LD_LIBRARY_PATH:=}"
	(
	pushd /build/gpdb/gpAux
	# shellcheck disable=SC1091
	source /opt/gcc_env.sh

	local max_load
	max_load=$(( $(ncpu) * 3 / 2))
	env IVY_HOME=/opt/releng/ivy_home \
		make \
		BLD_CC='ccache gcc' \
		rhel5_x86_64_CXX='ccache g++' \
		rhel6_x86_64_CXX='ccache g++' \
		GPROOT=/build/install \
		PARALLEL_BUILD=1 \
		parallelexec_maxlimit=${max_load} \
		dist
	)
}

make_cluster() {
	: "${LD_LIBRARY_PATH:=}"
	(
	# shellcheck disable=SC1091
	source /build/install/greenplum-db-devel/greenplum_path.sh
	env BLDWRAP_POSTGRES_CONF_ADDONS='fsync=off' make -C /build/gpdb/gpAux/gpdemo
	)
}

_main "$@"
