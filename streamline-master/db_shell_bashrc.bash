set -e -u -o pipefail

# shellcheck source=guest_common.bash
source "$(dirname "${BASH_SOURCE[0]}")"/../guest_common.bash
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
2. To run installcheck-good with planner, type:
  env PGOPTIONS='-c optimizer=off' make installcheck-good
3. If you made new commits on the host -- without catalog changes -- this might make your iterations faster:
  git fetch origin HEAD && git reset --hard FETCH_HEAD && make install -s -j8 -l12 -C /build/gpdb && gpstop -ari
4. To create a database, type:
  createdb
5. To run SQL, type:
  psql
	EOF
}

_main "$@"
