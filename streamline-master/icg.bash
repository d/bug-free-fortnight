#!/bin/bash

set -e -u -o pipefail
set -x

# shellcheck source=common.bash
source $(dirname $0)/../common.bash
# shellcheck source=streamline-master/guest_common.bash
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
	env PGOPTIONS='-c optimizer=on' make -C src/test installcheck-good
}

icg_planner() {
	pollute_cluster_env

	cd /build/gpdb
	make -C src/test installcheck-good
}

_main "$@"
