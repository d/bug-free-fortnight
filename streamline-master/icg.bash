#!/bin/bash

set -e -o pipefail
set -x

icg() {
	source /build/install/greenplum_path.sh
	source /build/gpdb/gpAux/gpdemo/gpdemo-env.sh
	
	cd /build/gpdb
	PGOPTIONS='-c optimizer=on' make installcheck-good
}

icg "$@"
