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
		time bugbuster
	else
		time icg_planner
		time bugbuster_planner
	fi
}

pollute_cluster_env() {
	: ${LD_LIBRARY_PATH:=}
	source /opt/gcc_env.sh
	source /build/install/greenplum-db-devel/greenplum_path.sh
	source /build/gpdb4/gpAux/gpdemo/gpdemo-env.sh
}

icg() {
	(
	pollute_cluster_env

	cd /build/gpdb4/src/test/regress
	env PGOPTIONS='-c optimizer=on' make installcheck-good
	)
}

icg_planner() {
	(
	pollute_cluster_env

	cd /build/gpdb4/src/test/regress
	make installcheck-good
	)
}

bugbuster_planner() {
	(
	pollute_cluster_env

	cd /build/gpdb4/src/test/regress
	make installcheck-bugbuster
	)
}

bugbuster() {
	(
	pollute_cluster_env

	cd /build/gpdb4/src/test/regress
	env PGOPTIONS='-c optimizer=on' make installcheck-bugbuster
	)
}

_main "$@"
