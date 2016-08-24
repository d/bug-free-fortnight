#!/bin/bash

set -e -u -o pipefail
set -x

_main() {
	clone_gpdb4
	make_sync_tools
}

make_sync_tools() {
	pushd /build/gpdb4/gpAux
	: ${LD_LIBRARY_PATH:=}
	time (
	source /opt/gcc_env.sh
	make sync_tools
	ln -svf /build/gpdb4/gpAux/ext/rhel5_x86_64/python-2.6.2 /opt
	)
	popd
}

clone_gpdb4() {
	if [[ ! -e /build/gpdb4 ]]; then
		git clone /workspace/gpdb4 /build/gpdb4
	fi
	pushd /build/gpdb4
	rsync -r /workspace/gpdb4/.git/modules .git
	git submodule update --init --recursive

	popd
}

_main "$@"
