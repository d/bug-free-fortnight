pollute_cluster_env() {
	set_user_env

	: "${LD_LIBRARY_PATH:=}"
	: "${PYTHONHOME:=$(default_python_home)}"

	# shellcheck disable=SC1091
	source /build/install/greenplum_path.sh
	# shellcheck disable=SC1091
	source /build/gpdb/gpAux/gpdemo/gpdemo-env.sh
}
