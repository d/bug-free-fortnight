#!/bin/bash

set -e -u -o pipefail
set -x

# shellcheck source=guest_common.bash
source $(dirname $0)/../guest_common.bash
# shellcheck source=streamline-master/guest_common.bash
source $(dirname $0)/guest_common.bash

_main() {
	local installcheck_mode
	parse_args "$@"

	if [[ "${installcheck_mode}" = orca ]]; then
		time icg
	else
		time icg_planner
	fi
}

parse_args() {
	local args=("$@")
	installcheck_mode=orca

	local opt
	local OPTIND OPTARG
	while getopts :m: opt "${args[@]+${args[@]}}" ; do
		case "${opt}" in
			m)
				installcheck_mode=${OPTARG}
				;;
			*)
				echo >&2 Unknown flag
				return 1
				;;
		esac
	done
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
