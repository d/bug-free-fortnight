set -e -u -o pipefail

# shellcheck source=streamline-master/guest_common.bash
source guest_common.bash

_main() {
	pollute_cluster_env
	useful_prompt
	cd /build/gpdb/src/test/regress
	friendly_message
	set +e
}

useful_prompt() {
	PS1='\w \h\$ '
}

friendly_message() {
	cat <<-EOF
1. To run installcheck-good with orca, type:
  env PGOPTIONS='-c optimizer=on' make installcheck-good
2. To create a database, type:
  createdb
3. To run SQL, type:
  psql
	EOF
}

_main "$@"
