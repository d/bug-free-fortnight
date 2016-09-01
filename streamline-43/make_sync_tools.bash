#!/bin/bash

set -e -u -o pipefail
set -x

_main() {
	time clone_gpdb4
	time make_sync_tools
}

make_sync_tools() {
	: ${LD_LIBRARY_PATH:=}
	(
	source /opt/gcc_env.sh
	pushd /build/gpdb4/gpAux
	make sync_tools
	ln -svf /build/gpdb4/gpAux/ext/rhel5_x86_64/python-2.6.2 /opt
	)
}

clone_gpdb4() {
	if [[ ! -e /build/gpdb4 ]]; then
		git clone --shared /workspace/gpdb4 /build/gpdb4
	fi
	pushd /build/gpdb4
	rsync -r /workspace/gpdb4/.git/modules .git
	git submodule update --init --recursive

	popd
}

_main "$@"
