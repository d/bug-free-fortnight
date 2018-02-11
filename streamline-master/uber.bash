#!/bin/bash

set -e -u -o pipefail

# shellcheck source=common.bash
source "$(dirname "$0")"/../common.bash

_main() {
	# testing for unset variable
	if [[ "${DEBUG+x}" = "x" ]]; then
		set -x
	fi

	local installcheck_mode
	local run_mode
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

	run "${container_id}" "${relpath}" "${run_mode}" "${installcheck_mode}"
}

create_container() {
	local image_id
	image_id=$1
	local workspace
	workspace=$(workspace)
	docker run --detach -ti \
		--init \
		--cap-add SYS_PTRACE \
		--volume /build \
		--volume gpdbccache:/ccache \
		--volume orca:/orca:ro \
		--volume "${workspace}":/workspace:ro \
		--env CCACHE_DIR=/ccache \
		"${image_id}"
}

_main "$@"
