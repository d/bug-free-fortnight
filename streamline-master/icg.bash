#!/bin/bash

set -e -u -o pipefail
set -x

readonly DIR=$(dirname "$0")
# shellcheck source=guest_common.bash
source "${DIR}"/../guest_common.bash
# shellcheck source=streamline-master/guest_common.bash
source "${DIR}"/guest_common.bash

_main() {
	local installcheck_mode
	parse_args "$@"

	case "${installcheck_mode}" in
		orca)
			time icg::orca
			;;
		planner)
			time icg::planner
			;;
		*)
			false
			;;
	esac
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

icg::orca() {
	icg '-c optimizer=on'
}

icg::planner() {
	icg '-c optimizer=off'
}

icg() {
	local pgoptions=$1

	pollute_cluster_env

	cd /build/gpdb
	env "PGOPTIONS=$pgoptions" make -C src/test/regress installcheck-good
}

_main "$@"
