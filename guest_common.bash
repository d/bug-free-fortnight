set_user_env() {
	: "${USER:="$(id -un)"}"
	: "${LOGNAME:=${USER}}"
	export USER LOGNAME
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
	elif getconf _NPROCESSORS_ONLN; then
		true
	else
		echo 8
	fi
}

clone_gpdb() {
	local repo
	repo=$1

	if [[ ! -e /build/gpdb ]]; then
		git clone --shared "/workspace/${repo}" /build/gpdb
	fi
	(
	pushd /build/gpdb
	rsync -r "/workspace/${repo}/.git/modules" .git
	git submodule update --init --recursive
	)
}

