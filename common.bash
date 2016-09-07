parse_opts() {
	optimizer=true
	interactive=false
	stale_orca=false
	local opt
	for opt in "$@"; do
		case "${opt}" in
			--planner|--no-optimizer)
				optimizer=false
				;;
			--interactive)
				interactive=true
				;;
			--use-stale-orca)
				stale_orca=true
				;;
		esac
	done

	if [[ "${interactive}" = true && "${optimizer}" = false ]]; then
		printf >&2 -- '--interactive and --no-optimizer are mutually exclusive\n'
		return 1
	fi
}

container_name() {
	local container_id
	readonly container_id=$1
	docker ps --format '{{.Names}}' --filter id="${container_id}"
}


build_orca() {
	if [[ "${stale_orca:-}" = true ]]; then
		return 0
	fi

	local workspace
	workspace=$(workspace)

	docker run --rm \
		--volume gpdbccache:/ccache \
		--volume orca:/orca \
		--volume "${workspace}":/workspace:ro \
		--env CCACHE_DIR=/ccache \
		--env CCACHE_UMASK=0000 \
		yolo/orcadev:centos5 \
		/workspace/bug-free-fortnight/streamline-master/build_orca.bash
}

build_image() {
	local dir
	dir=$(dirname "$0")
	docker build -q "${dir}"
}

run_in_container() {
	local container_id
	local -a path_and_args

	readonly container_id=$1
	shift

	path_and_args=("$@")

	docker exec "${container_id}" "${path_and_args[@]}"
}

workspace() {
	local -r whereami=$(absdir)

	dirname "$(dirname "${whereami}")"
}

absdir() {
	(
	cd "$(dirname "$0")"
	pwd
	)
}

set_ccache_max_size() {
	local -r cache_size=8G

	docker run --rm \
		--volume gpdbccache:/ccache \
		yolo/gpdbdev:centos6 \
		chmod a+rw /ccache

	docker run --rm \
		--volume gpdbccache:/ccache \
		--env CCACHE_DIR=/ccache \
		--env CCACHE_UMASK=0000 \
		yolo/gpdbdev:centos6 \
		ccache -M ${cache_size}
}

