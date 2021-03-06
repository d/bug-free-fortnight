parse_opts() {
	installcheck_mode=orca
	run_mode=icg
	stale_orca=false
	existential_angst=false
	build_mode=opt
	local opt
	for opt in "$@"; do
		case "${opt}" in
		--planner | --no-optimizer)
			installcheck_mode=planner
			;;
		--interactive)
			run_mode=interactive
			;;
		--interactive-after-icg)
			run_mode=interactive_after_icg
			;;
		--use-stale-orca)
			stale_orca=true
			;;
		--existential-angst)
			existential_angst=true
			;;
		--enable-debug)
			build_mode=debug
			;;
		esac
	done

	if [[ "${run_mode}" = interactive && "${installcheck_mode}" = planner ]]; then
		printf >&2 -- '--interactive and --no-optimizer are mutually exclusive\n'
		return 1
	fi
}

container_name() {
	local container_id
	readonly container_id=$1
	docker ps --format '{{.Names}}' --filter id="${container_id}"
}

is_anxious() {
	[[ "${DEBUG+x}" = "x" && "${existential_angst:-}" = "true" ]]
}

build_orca() {
	if [[ "${stale_orca:-}" = true ]]; then
		return 0
	fi

	local workspace
	workspace=$(workspace)

	local orca_container_id
	orca_container_id=$(
		docker run --detach \
			--volume gpdbccache:/ccache \
			--volume orca:/orca \
			--volume "${workspace}":/workspace:ro \
			--env CCACHE_DIR=/ccache \
			--env CCACHE_UMASK=0000 \
			yolo/orcadev:centos5 \
			/workspace/bug-free-fortnight/streamline-master/build_orca.bash
	)
	if is_anxious; then
		(
			trap "cleanup_container \"${orca_container_id}\"" EXIT
			docker attach --sig-proxy=false "${orca_container_id}"
		)
	else
		local orca_build_status
		orca_build_status=$(
			trap "cleanup_container \"${orca_container_id}\"" INT
			docker wait "${orca_container_id}"
		)
		if [[ "${orca_build_status}" -ne 0 ]]; then
			docker logs "${orca_container_id}"
		fi
		docker rm "${orca_container_id}"
		return "${orca_build_status}"
	fi
}

build_image() {
	local dir
	dir=$(dirname "$0")
	if is_anxious; then
		docker build "${dir}" >&2
	fi
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

relpath_from_workspace() {
	local whereami this_dir parent_abspath parent_dir

	whereami=$(absdir)
	this_dir=$(basename "${whereami}")
	parent_abspath=$(dirname "${whereami}")
	parent_dir=$(basename "${parent_abspath}")
	echo "${parent_dir}"/"${this_dir}"
}

build_gpdb() {
	local container_id
	readonly container_id=$1
	local relpath
	readonly relpath=$2
	local build_mode
	readonly build_mode=$3

	local -a build_args=()
	if [[ "${build_mode}" == debug ]]; then
		build_args+=(
			-d
		)
	fi

	local -r path=/workspace/${relpath}/build_gpdb.bash
	run_in_container "${container_id}" "${path}" "${build_args[@]+${build_args[@]}}"
}

cleanup_container() {
	local container_id
	readonly container_id=$1
	docker rm --force --volumes "${container_id}"
}

cleanup() {
	local container_id
	readonly container_id=$1
	local repo
	readonly repo=$2

	local workspace
	workspace=$(workspace)

	docker cp "${container_id}":/build/gpdb/src/test/regress/regression.diffs "${workspace}"/"${repo}"/src/test/regress || :
	cleanup_container "${container_id}"
}

run() {
	local container_id
	readonly container_id=$1
	local relpath
	readonly relpath=$2
	local run_mode
	readonly run_mode=$3
	local installcheck_mode
	readonly installcheck_mode=$4

	case "${run_mode}" in
	interactive)
		docker exec -ti "${container_id}" /workspace/"${relpath}"/db_shell.bash
		return 0
		;;
	icg)
		icg "${container_id}" "${relpath}" "${installcheck_mode}"
		;;
	interactive_after_icg)
		if icg "${container_id}" "${relpath}" "${installcheck_mode}"; then
			echo "ICG passed."
			true
		else
			echo "ICG failed: returned status $?"
		fi
		docker exec -ti "${container_id}" /workspace/"${relpath}"/db_shell.bash
		return 0
		;;
	*)
		return 1
		;;
	esac
}

icg() {
	local container_id
	readonly container_id=$1
	local relpath
	readonly relpath=$2
	local installcheck_mode
	readonly installcheck_mode=$3

	case "${installcheck_mode}" in
	orca)
		run_in_container "${container_id}" /workspace/"${relpath}"/icg.bash
		;;
	planner)
		run_in_container "${container_id}" /workspace/"${relpath}"/icg.bash -m planner
		;;
	*)
		return 1
		;;
	esac
}
