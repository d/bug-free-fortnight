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

ext_path() {
	# This is safe only when we're in a subshell
	shopt -s nullglob

	# quoting around the pattern is not only unnecessary, it's also wrong,
	# because word splitting happens **before** pathname expansion
	local ext_dirs=( /build/gpdb/gpAux/ext/* )

	# guard against empty
	[[ "${ext_dirs[@]+x}" == "x" ]]

	# guard against multiple subdirs
	[[ "${#ext_dirs[@]}" -eq "1" ]]

	echo "${ext_dirs[0]}"
}

ncpu() {
	if nproc; then
		true
	else
		echo 8
	fi
}
