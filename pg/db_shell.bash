#!/bin/bash

set -u -o pipefail
_main() {
	su -c "tmux -CC new" -l postgres
}

_main "$@"
