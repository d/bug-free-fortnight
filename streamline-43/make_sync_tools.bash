#!/bin/bash

set -e -u -o pipefail
set -o posix
set -x

# shellcheck source=streamline-43/guest_common.bash
source $(dirname $0)/guest_common.bash

_main() {
	local repo
	repo=$1
	time clone_gpdb "${repo}"
	time make_sync_tools
}

make_sync_tools() {
	: "${LD_LIBRARY_PATH:=}"
	(
	# shellcheck disable=SC1091
	source /opt/gcc_env.sh
	pushd /build/gpdb/gpAux
	make sync_tools

	local ext_dir
	readonly ext_dir=$(ext_path)

	ln -svf "${ext_dir}/python-2.6.2" /opt
	)
}

clone_gpdb() {
	local repo
	repo=$1

	if [[ ! -e /build/gpdb ]]; then
		git clone --shared "/workspace/${repo}" /build/gpdb
	fi
	(
	pushd /build/gpdb
	rsync -r "/workspace/${repo}/.git/modules" .git
	git submodule update --init --recursive
	)
}

_main "$@"
