#!/bin/bash

set -e -u -o pipefail

_main() {
	find . -type f -name "*.bash" -exec shellcheck "$@" --exclude SC2164 --exclude SC2064 --shell bash {} +
	find . -type f -name "*.bash" -exec shfmt -d {} +
}

_main "$@"
