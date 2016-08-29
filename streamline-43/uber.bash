#!/bin/bash

set -u -e -o pipefail

_main() {
	# testing for unset variable
	if [[ "${DEBUG+x}" = "x" ]]; then
		set -x
	fi

	local image_id
	readonly image_id=$(build_image)

	build_orca

	local container_id
	readonly container_id=$(create_container ${image_id})

	trap "cleanup ${container_id}" EXIT

	set_ccache_max_size ${container_id}

	local -r relpath=$(relpath_from_workspace)

	make_sync_tools ${container_id} ${relpath}

	build_gpdb4 ${container_id} ${relpath}
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

build_orca() {
	local workspace
	readonly workspace=$(workspace)

	docker run --rm -ti \
		--volume gpdbccache:/ccache \
		--volume orca:/orca \
		--volume ${workspace}:/workspace:ro \
		--env CCACHE_DIR=/ccache \
		--env CCACHE_UMASK=0000 \
		yolo/orcadev:centos5 \
		/workspace/bug-free-fortnight/streamline-master/build_orca.bash
}

cleanup() {
	local container_id
	container_id=$1

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
	docker run --detach -ti \
		--volume gpdbccache:/ccache \
		--volume gpdb4releng:/opt/releng \
		--volume ${workspace}:/workspace:ro \
		--env CCACHE_DIR=/ccache \
		${image_id}
}

set_ccache_max_size() {
	local container_id
	readonly container_id=$1
	local -r cache_size=8G

	run_in_container ${container_id} "ccache -M ${cache_size}"
}

relpath_from_workspace() {
	local -r whereami=$(absdir)
	local -r this_dir=$(basename ${whereami})
	echo $(basename $(dirname ${whereami}))/${this_dir}
}

workspace() {
	local -r whereami=$(absdir)

	dirname $(dirname ${whereami})
}

absdir() {
	(
	cd "$(dirname "$0")"
	pwd
	)
}

run_in_container() {
	local container_id
	local path

	container_id=$1
	path=$2

	docker exec ${container_id} ${path}
}

build_image() {
	local dir
	dir=$(dirname $0)
	docker build -q ${dir}
}

_main "$@"
