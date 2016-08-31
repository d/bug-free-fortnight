#!/bin/bash

set -e -o pipefail
set -x

_main() {
	time icg
}

icg() {
	source /build/install/greenplum_path.sh
	source /build/gpdb/gpAux/gpdemo/gpdemo-env.sh
	
	cd /build/gpdb
	PGOPTIONS='-c optimizer=on' make installcheck-good
}

_main "$@"
