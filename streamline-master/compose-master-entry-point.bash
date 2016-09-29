#!/bin/bash

set -e -u -o pipefail
set -x

_main() {
	if cluster_initialized; then
		start_cluster
	else
		initialize_cluster
	fi

	keep_running
}

pollute_cluster_env() {
	USER="$(id -un)"
	LOGNAME="${USER}"
	export USER LOGNAME

	: "${LD_LIBRARY_PATH:=}"
	: "${PYTHONHOME:=$(default_python_home)}"

	# shellcheck disable=SC1091
	source /build/install/greenplum_path.sh
}

start_cluster() {
	pollute_cluster_env
	local MASTER_DATA_DIRECTORY=/data/master/gpseg-1
	export MASTER_DATA_DIRECTORY
	gpstart -a -d "${MASTER_DATA_DIRECTORY}"
}

cluster_initialized() {
	[[ -d /data/master/gpseg-1 ]]
}

initialize_cluster() {
	for host in master seg1 seg2 seg3; do
		ssh -o StrictHostKeyChecking=no "${host}" true
	done

	generate_configs
	make_datadir_but_we_should_elinimate_this
	initdb
}

initdb() {
	: "${LD_LIBRARY_PATH:=}"
	: "${PYTHONHOME:=$(default_python_home)}"
	# shellcheck disable=SC1091
	source /build/install/greenplum_path.sh
	gpinitsystem -a -c gpconfigs/gpinitsystem_config -h gpconfigs/hostfile_gpinitsystem
	cat >> /data/master/gpseg-1/pg_hba.conf <<IYI_GECELER
host	all	gpadmin		samenet		trust
IYI_GECELER
	pkill -HUP postgres
}

default_python_home() {
	python <<-EOF
	import sys
	print(sys.prefix)
	EOF
}

generate_configs() {
	mkdir -p gpconfigs
	cat > gpconfigs/hostfile_gpinitsystem <<KANKA
seg1
seg2
seg3
KANKA

	cat > gpconfigs/gpinitsystem_config <<GUNAYDIN
ARRAY_NAME="IYI GECELER Greenplum DW"
SEG_PREFIX=gpseg
PORT_BASE=40000 
declare -a DATA_DIRECTORY=(/data1/primary)
MASTER_HOSTNAME=master
MASTER_DIRECTORY=/data/master
MASTER_PORT=5432 
TRUSTED_SHELL=ssh
CHECK_POINT_SEGMENTS=8
ENCODING=UNICODE
GUNAYDIN
}

make_datadir_but_we_should_elinimate_this() {
	sudo mkdir -p /data/master
	sudo chown -R gpadmin /data
	for segment in seg1 seg2 seg3; do
		ssh "${segment}" sudo mkdir -p /data1/primary
		ssh "${segment}" sudo chown -R gpadmin /data1
	done
}

keep_running() {
	while true; do
		sleep 600
	done
}

_main "$@"
