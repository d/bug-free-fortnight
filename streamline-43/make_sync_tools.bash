#!/bin/bash

set -e -u -o pipefail
set -o posix
set -x

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
	ln -svf /build/gpdb/gpAux/ext/rhel5_x86_64/python-2.6.2 /opt
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
