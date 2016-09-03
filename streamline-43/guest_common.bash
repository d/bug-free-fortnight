pollute_cluster_env() {
	USER="$(id -un)"
	LOGNAME="${USER}"
	export USER LOGNAME

	: ${LD_LIBRARY_PATH:=}
	source /opt/gcc_env.sh
	source /build/install/greenplum-db-devel/greenplum_path.sh
	source /build/gpdb4/gpAux/gpdemo/gpdemo-env.sh
}

default_python_home() {
	python <<-EOF
	import sys
	print(sys.prefix)
	EOF
}
