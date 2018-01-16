#!/bin/bash

set -e -u -o pipefail
set -o posix
set -x

# shellcheck source=guest_common.bash
source $(dirname $0)/../guest_common.bash
# shellcheck source=streamline-43/guest_common.bash
source $(dirname $0)/guest_common.bash

_main() {
	local repo
	repo=$1
	time clone_gpdb_with_submodules "${repo}"
	time giant_hack_because_of_uid_min_difference
	time make_sync_tools
}

# same caveat as ext_path, see guest_common.bash
python_path() {
	local ext_path
	ext_path=$1

	shopt -s nullglob

	local -a python_paths
	# this would have been much easier to read if we could pipe the subshell
	# but there appears to be a Bash 3.2 bug where `read` does read
	# anything when placed after a pipe like foo | read A
	read -r -a python_paths <<<"$(find "${ext_path}" -maxdepth 1 -name 'python-*')"

	[[ "${#python_paths[@]}" -eq "1" ]] || return 1

	echo "${python_paths[0]}"
}

giant_hack_because_of_uid_min_difference() {
	sudo chmod -R o+rw /opt/releng
}

make_sync_tools() {
	: "${LD_LIBRARY_PATH:=}"
	(
	# shellcheck disable=SC1091
	pushd /build/gpdb/gpAux
	make sync_tools

	set -e
	local ext_dir
	readonly ext_dir=$(ext_path)
	local python_path
	readonly python_path=$(python_path "${ext_dir}")

	ln -svf "${python_path}" /opt
	)
}

_main "$@"
