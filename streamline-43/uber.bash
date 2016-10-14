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
	parse_opts "$@"

	local image_id
	image_id=$(build_image)

	local container_id
	container_id=$(create_container "${image_id}")

	trap "cleanup ${container_id}" EXIT

	set_ccache_max_size

	time build_orca

	local -r relpath=$(relpath_from_workspace)

	make_sync_tools "${container_id}" "${relpath}"

	build_gpdb4 "${container_id}" "${relpath}"

	if [[ "${interactive}" = true ]]; then
		docker exec -ti "${container_id}" /workspace/bug-free-fortnight/streamline-43/db_shell.bash
		return 0
	fi

	if [[ "$optimizer" = true ]]; then
		run_in_container "${container_id}" /workspace/"${relpath}"/icg.bash
	else
		run_in_container "${container_id}" /workspace/"${relpath}"/icg.bash --no-optimizer
	fi
}

make_sync_tools() {
	local container_id
	readonly container_id=$1
	local relpath
	readonly relpath=$2

	local -r path=/workspace/${relpath}/make_sync_tools.bash

	run_in_container "${container_id}" "${path}"
}

build_gpdb4() {
	local container_id
	readonly container_id=$1
	local relpath
	readonly relpath=$2

	local -r path=/workspace/${relpath}/build_gpdb4.bash
	run_in_container "${container_id}" "${path}"
}

cleanup() {
	local container_id
	readonly container_id=$1

	local workspace
	workspace=$(workspace)

	docker cp "${container_id}":/build/gpdb4/src/test/regress/regression.diffs "${workspace}"/gpdb4/src/test/regress || :
	docker rm --force "${container_id}"
}

create_container() {
	local image_id
	image_id=$1
	local workspace
	workspace=$(workspace)
	docker run --detach -ti \
		--cap-add SYS_PTRACE \
		--volume gpdbccache:/ccache \
		--volume gpdb4releng:/opt/releng \
		--volume orca:/orca:ro \
		--volume "${workspace}":/workspace:ro \
		--env CCACHE_DIR=/ccache \
		--env IVYREPO_HOST="${IVYREPO_HOST}" \
		--env IVYREPO_REALM="${IVYREPO_REALM}" \
		--env IVYREPO_USER="${IVYREPO_USER}" \
		--env IVYREPO_PASSWD="${IVYREPO_PASSWD}" \
		"${image_id}"
}

relpath_from_workspace() {
	local whereami this_dir parent_abspath parent_dir

	whereami=$(absdir)
	this_dir=$(basename "${whereami}")
	parent_abspath=$(dirname "${whereami}")
	parent_dir=$(basename "${parent_abspath}")
	echo "${parent_dir}"/"${this_dir}"
}

_main "$@"
