#!/bin/bash

set -u -e -o pipefail

# shellcheck source=common.bash
source "$(dirname "$0")"/../common.bash

_main() {
	# testing for unset variable
	if [[ "${DEBUG+x}" = "x" ]]; then
		set -x
	fi

	local optimizer
	local interactive
	local stale_orca
	local existential_angst
	local build_mode
	parse_opts "$@"

	local image_id
	image_id=$(build_image)

	local container_id
	container_id=$(create_container "${image_id}")

	trap "cleanup ${container_id} gpdb" EXIT

	set_ccache_max_size

	time build_orca

	local -r relpath=$(relpath_from_workspace)

	build_gpdb "${container_id}" "${relpath}" "${build_mode}"

	if [[ "${interactive}" = true ]]; then
		docker exec -ti "${container_id}" /workspace/bug-free-fortnight/streamline-master/db_shell.bash
		return 0
	fi

	if [[ "$optimizer" = true ]]; then
		run_in_container "${container_id}" /workspace/bug-free-fortnight/streamline-master/icg.bash
	else
		run_in_container "${container_id}" /workspace/bug-free-fortnight/streamline-master/icg.bash --no-optimizer
	fi
}

create_container() {
	local image_id
	image_id=$1
	local workspace
	workspace=$(workspace)
	docker run --detach -ti \
		--cap-add SYS_PTRACE \
		--volume gpdbccache:/ccache \
		--volume orca:/orca:ro \
		--volume "${workspace}":/workspace:ro \
		--env CCACHE_DIR=/ccache \
		"${image_id}"
}

_main "$@"
