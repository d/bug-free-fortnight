#!/bin/bash

set -u -e -o pipefail

source $(dirname $0)/../common.bash

_main() {
	# testing for unset variable
	if [[ "${DEBUG+x}" = "x" ]]; then
		set -x
	fi

	local image_id
	readonly image_id=$(build_image)

	local container_id
	container_id=$(create_container ${image_id})

	trap "cleanup ${container_id}" INT ERR

	set_ccache_max_size

	build_orca

	local -r relpath=$(relpath_from_workspace)

	make_sync_tools ${container_id} ${relpath}

	build_gpdb4 ${container_id} ${relpath}

	run_in_container ${container_id} /workspace/${relpath}/icg.bash
}

make_sync_tools() {
	local container_id
	readonly container_id=$1
	local relpath
	readonly relpath=$2

	local -r path=/workspace/${relpath}/make_sync_tools.bash

	run_in_container ${container_id} ${path}
}

build_gpdb4() {
	local container_id
	readonly container_id=$1
	local relpath
	readonly relpath=$2

	local -r path=/workspace/${relpath}/build_gpdb4.bash
	run_in_container ${container_id} "/bin/bash -i ${path}"
}

cleanup() {
	local container_id
	readonly container_id=$1

	local workspace
	workspace=$(workspace)

	docker cp ${container_id}:/build/gpdb4/src/test/regress/regression.diffs ${workspace}/gpdb4/src/test/regress || :
	docker rm --force ${container_id}
}

create_container() {
	local image_id
	image_id=$1
	local workspace
	workspace=$(workspace)
	docker run --detach -i \
		--volume gpdbccache:/ccache \
		--volume gpdb4releng:/opt/releng \
		--volume orca:/orca:ro \
		--volume ${workspace}:/workspace:ro \
		--env CCACHE_DIR=/ccache \
		--env IVYREPO_HOST="${IVYREPO_HOST}" \
		--env IVYREPO_REALM="${IVYREPO_REALM}" \
		--env IVYREPO_USER="${IVYREPO_USER}" \
		--env IVYREPO_PASSWD="${IVYREPO_PASSWD}" \
		${image_id}
}

relpath_from_workspace() {
	local -r whereami=$(absdir)
	local -r this_dir=$(basename ${whereami})
	echo $(basename $(dirname ${whereami}))/${this_dir}
}

_main "$@"
