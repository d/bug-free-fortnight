#!/bin/bash

set -e -u -o pipefail
set -x

# shellcheck source=common.bash
source $(dirname $0)/../common.bash
# shellcheck source=streamline-43/guest_common.bash
source $(dirname $0)/guest_common.bash

_main() {
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
