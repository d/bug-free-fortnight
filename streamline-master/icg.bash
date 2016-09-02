#!/bin/bash

set -e -u -o pipefail
set -x

source $(dirname $0)/../common.bash
source $(dirname $0)/guest_common.bash

_main() {
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

_main "$@"
