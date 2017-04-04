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

	make_sync_tools "${container_id}" "${relpath}" gpdb
	gross_hack_to_remove_libz_until_we_pay_down_that_fucking_debt "${container_id}"

	build_gpdb "${container_id}" "${relpath}" "${build_mode}"

	run "${container_id}" "${relpath}" "${run_mode}" "${installcheck_mode}"
}

gross_hack_to_remove_libz_until_we_pay_down_that_fucking_debt() {
	local container_id
	readonly container_id=$1
	docker exec "${container_id}" find /build/gpdb/gpAux/ext \( -name 'libz.so' -or -name 'libz.so.*' -or -name 'libz.a' \) -print -delete
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

_main "$@"
