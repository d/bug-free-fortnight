#!/bin/bash

set -e -u -o pipefail

_main() {
	find . -name "*.bash" -exec shellcheck "$@" --exclude SC2164 --exclude SC2064 --shell bash {} +
}

_main "$@"
