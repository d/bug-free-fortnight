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

	local path
	path=/workspace/ci-infrastructure/streamline-master/build_the_universe.bash
	run_in_container ${container_id} ${path}
}

create_container() {
	local image_id
	image_id=$1
	local workspace
	workspace=$(dirname $(dirname $(dirname $0)))
	docker run --detach -ti --volume ${workspace}:/workspace:ro ${image_id}
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
