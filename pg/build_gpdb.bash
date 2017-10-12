#!/bin/bash

set -e -u -o pipefail

# shellcheck source=guest_common.bash
source $(dirname $0)/../guest_common.bash

_main() {
	# Until 8.4 we couldn't really do out-of-tree build
	git clone --shared /workspace/postgres /src/pg
	pushd /src/pg
	./configure --enable-depend --enable-debug --enable-cassert --prefix /usr/local CC='ccache cc'

	local max_load
	max_load=$(( $(ncpu) * 3 / 2))

	make "-j${max_load}" "-l${max_load}" install

	chpst -u postgres initdb
	chpst -u postgres pg_ctl -l /tmp/log start
}

_main "$@"
