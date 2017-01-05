pollute_cluster_env() {
	set_user_env

	: "${LD_LIBRARY_PATH:=}"
	# shellcheck disable=SC1091
	source /opt/gcc_env.sh
	# shellcheck disable=SC1091
	source /build/install/greenplum_path.sh
	# shellcheck disable=SC1091
	source /build/gpdb/gpAux/gpdemo/gpdemo-env.sh
}

