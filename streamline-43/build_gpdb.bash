#!/bin/bash

set -e -u -o pipefail
set -x
set -o posix

# shellcheck source=guest_common.bash
source $(dirname $0)/../guest_common.bash
# shellcheck source=streamline-43/guest_common.bash
source $(dirname $0)/guest_common.bash

_main() {
	local prefix
	prefix=/build/install

	local build_mode
	parse_args "$@"

	time inject_orca
	time build_gpdb4 "${prefix}"
	time make_cluster "${prefix}"
}

parse_args() {
	local args=("$@")
	build_mode=opt
	vanilla_orca=false

	local opt
	local OPTIND
	while getopts :dJ opt "${args[@]+${args[@]}}" ; do
		case "${opt}" in
			d)
				build_mode=debug
				;;
			J)
				vanilla_orca=true
				;;
			*)
				echo >&2 Unknown flag
				return 1
				;;
		esac
	done
}

inject_orca() {
	local ext_dir

	if [[ "${vanilla_orca:-}" = true ]]; then
		return 0
	fi

	readonly ext_dir=$(ext_path)

	tar xf /orca/bin_orca.tar -C "${ext_dir}"
}

build_gpdb4() {
	local prefix
	prefix=$1

	: "${LD_LIBRARY_PATH:=}"
	(
	pushd /build/gpdb/gpAux
	# shellcheck disable=SC1091
	source /opt/gcc_env.sh

	local target
	case "${build_mode}" in
		debug)
			target=devel
			;;
		*)
			target=dist
			;;
	esac

	local max_load
	max_load=$(( $(ncpu) * 3 / 2))

	local -a MAKEVARS=(
	"INSTLOC=${prefix}"
	'BLD_CC=ccache gcc'
	'CXX=ccache g++'
	'GPROOT=/build/install'
	'PARALLEL_BUILD=1'
	"parallelexec_maxlimit=${max_load}"
	"PARALLEL_MAKE_OPTS=-j${max_load} -l${max_load} --output-sync=target"
	'GPDBGOPT=on'
	)
	env IVY_HOME=/opt/releng/ivy_home \
		make \
		"${MAKEVARS[@]}" \
		"${target}"
	)
}

make_cluster() {
	local prefix
	prefix=$1
	: "${LD_LIBRARY_PATH:=}"

	(
	set_user_env
	# shellcheck disable=SC1090
	source "${prefix}"/greenplum_path.sh
	env BLDWRAP_POSTGRES_CONF_ADDONS='fsync=off' make -C /build/gpdb/gpAux/gpdemo
	)
}

_main "$@"
