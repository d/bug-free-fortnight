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
	time clone_gpdb "${repo}"
	time giant_hack_because_of_uid_min_difference
	time make_sync_tools
}

# same caveat as ext_path, see guest_common.bash
python_path() {
	local ext_path
	ext_path=$1

	shopt -s nullglob

	local python_paths=( ${ext_path}/python-* )

	[[ "${#python_paths[@]}" -eq "1" ]]

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

	local ext_dir
	readonly ext_dir=$(ext_path)

	ln -svf "$(python_path "${ext_dir}")" /opt
	)
}

_main "$@"
