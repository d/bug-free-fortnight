#!/bin/bash

set -u -e -o pipefail

source $(dirname $0)/../common.bash

_main() {
	# testing for unset variable
	if [[ "${DEBUG+x}" = "x" ]]; then
		set -x
	fi

	local image_id
	image_id=$(build_image)

	build_orca

	local container_id
	container_id=$(create_container ${image_id})

	trap "cleanup ${container_id}" INT ERR

	local container_name
	readonly container_name="$(container_name ${container_id})"
	friendly_message ${container_name}

	set_ccache_max_size

	local -r path=/workspace/bug-free-fortnight/streamline-master/build_gpdb.bash
	run_in_container ${container_id} ${path}

}

friendly_message() {
	local container_name
	readonly container_name=$1

	echo "Building Xerces, GPOS, ORCA, and GPDB"
	echo "When it is done, run the following command to interact with the cluster, or run ICG:"
	echo "docker exec -ti ${container_name} /workspace/bug-free-fortnight/streamline-master/db_shell.bash"
}

container_name() {
	local container_id
	readonly container_id=$1
	docker ps --format '{{.Names}}' --filter id=${container_id}
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
	readonly workspace=$(workspace)
	docker run --detach -ti \
		--volume gpdbccache:/ccache \
		--volume orca:/orca:ro \
		--volume ${workspace}:/workspace:ro \
		--env CCACHE_DIR=/ccache \
		${image_id}
}

_main "$@"
