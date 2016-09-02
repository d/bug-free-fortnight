#!/bin/bash

set -u -e -o pipefail

source $(dirname $0)/../common.bash

_main() {
	# testing for unset variable
	if [[ "${DEBUG+x}" = "x" ]]; then
		set -x
	fi

	local optimizer
	local interactive
	parse_opts "$@"

	local image_id
	image_id=$(build_image)

	build_orca

	local container_id
	container_id=$(create_container ${image_id})

	trap "cleanup ${container_id}" EXIT

	set_ccache_max_size

	local -r path=/workspace/bug-free-fortnight/streamline-master/build_gpdb.bash
	run_in_container ${container_id} ${path}

	if [[ "${interactive}" = true ]]; then
		docker exec -ti "${container_id}" /workspace/bug-free-fortnight/streamline-master/db_shell.bash
		return 0
	fi

	if [[ "$optimizer" = true ]]; then
		run_in_container ${container_id} /workspace/bug-free-fortnight/streamline-master/icg.bash
	else
		run_in_container ${container_id} /workspace/bug-free-fortnight/streamline-master/icg.bash --no-optimizer
	fi
}

cleanup() {
	local container_id
	readonly container_id=$1

	local workspace
	workspace=$(workspace)

	docker cp ${container_id}:/build/gpdb/src/test/regress/regression.diffs ${workspace}/gpdb/src/test/regress || :
	docker rm --force ${container_id}
}

create_container() {
	local image_id
	image_id=$1
	local workspace
	workspace=$(workspace)
	docker run --detach -i \
		--volume gpdbccache:/ccache \
		--volume orca:/orca:ro \
		--volume ${workspace}:/workspace:ro \
		--env CCACHE_DIR=/ccache \
		${image_id}
}

_main "$@"
