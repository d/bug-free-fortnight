set -e -u -o pipefail

_main() {
	pollute_env
	useful_prompt
	cd /build/gpdb/src/test/regress
	friendly_message
	set +e
}

pollute_env() {
	: ${LD_LIBRARY_PATH:=}
	: ${PYTHONHOME:=$(default_python_home)}

	source /build/install/greenplum_path.sh
	source /build/gpdb/gpAux/gpdemo/gpdemo-env.sh
}

useful_prompt() {
	PS1='\w \h\$ '
}

default_python_home() {
	python <<-EOF
	import sys
	print(sys.prefix)
	EOF
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
