pollute_cluster_env() {
	USER="$(id -un)"
	LOGNAME="${USER}"
	export USER LOGNAME

	: "${LD_LIBRARY_PATH:=}"
	# shellcheck disable=SC1091
	source /opt/gcc_env.sh
	# shellcheck disable=SC1091
	source /build/install/greenplum-db-devel/greenplum_path.sh
	# shellcheck disable=SC1091
	source /build/gpdb/gpAux/gpdemo/gpdemo-env.sh
}

default_python_home() {
	python <<-EOF
	import sys
	print(sys.prefix)
	EOF
}
