#!/bin/bash

set -e -u -o pipefail
set -x

source $(dirname $0)/../common.bash

_main() {
	USER="$(id -un)"
	LOGNAME="${USER}"
	export USER LOGNAME

	local optimizer
	parse_opts "$@"

	if [[ "${optimizer}" = true ]]; then
		time icg
	else
		time icg_planner
	fi
}

icg() {
	pollute_cluster_env
	
	cd /build/gpdb
	env PGOPTIONS='-c optimizer=on' make installcheck-good
}

icg_planner() {
	pollute_cluster_env

	cd /build/gpdb
	make installcheck-good
}

pollute_cluster_env() {
	: ${LD_LIBRARY_PATH:=}
	source /build/install/greenplum_path.sh
	source /build/gpdb/gpAux/gpdemo/gpdemo-env.sh
}

_main "$@"
