#!/bin/bash

set -u -e -o pipefail

_main() {
	# testing for unset variable
	if [[ "${DEBUG+x}" = "x" ]]; then
		set -x
	fi

	local image_id
	image_id=$(build_image)

	local container_id
	container_id=$(create_container ${image_id})

	trap "cleanup ${container_id}" INT

	set_ccache_max_size ${container_id}

	local path
	path=/workspace/bug-free-fortnight/streamline-master/build_the_universe.bash
	run_in_container ${container_id} ${path}

}

cleanup() {
	local container_id
	container_id=$1

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
	docker run --detach -ti --volume gpdbccache:/home/gpadmin/.ccache --volume ${workspace}:/workspace:ro ${image_id}
}

set_ccache_max_size() {
	local container_id
	readonly container_id=$1
	local -r cache_size=8G

	run_in_container ${container_id} "ccache -M ${cache_size}"
}

workspace() {
	local whereami
	whereami=$(
		cd $(dirname $0)
		pwd
	)

	dirname $(dirname ${whereami})
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
