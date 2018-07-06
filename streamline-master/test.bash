#!/bin/bash

set -e -u -o pipefail
set -x

_main() {
	it_has_locale en_US.utf8

	it_has_gcc

	it_has_libc_objects

	it_has_working_cxx

	it_has_modern_cmake

	it_has_modern_ccache

	it_has_ninja_17

	it_has_executables

	it_has_python_modules_visible_to_every_user
}

it_has_locale() {
	local -r locale_name=$1
	locale -a | grep -F "${locale_name}"
}

it_has_gcc() {
	type -p gcc
	type -p g++
	type -p cc
	type -p c++
}

it_has_libc_objects() {
	(
	set -e
	pushd "$(mktemp -d -t simple_compilation.XXX)"
	cat > hello.c <<HELLO
#include <string.h>
int main() { return 0; }
HELLO
	gcc -D_GNU_SOURCE -o hello hello.c
	./hello
	)
}

it_has_working_cxx() {
	(
	pushd "$(mktemp -d -t simple_cxx.XXX)"
	cat > hello.cc <<HELLO
#include <iostream>
int main() { std::cout << 1ul << '\\n'; }
HELLO
	c++ -O -o hello hello.cc
	./hello
	)
}

it_has_modern_cmake() {
	local cmake_version
	readonly cmake_version=$(cmake --version 2>/dev/null)

	check_version_major_minor "${cmake_version}" 3 6
}

check_version_major_minor() {
	local version
	readonly version=$(sed 's/[^0-9]\+/ /g' <<< "$1")
	local major minor
	readonly major=$2
	readonly minor=$3

	local version_check_awk_script
	readonly version_check_awk_script=$(mktemp -t version_check.XXX.awk)

	cat > "${version_check_awk_script}" << CMAKE_VERSION_CHECK
	{
		if (\$1 > ${major} || (\$1 == ${major} && \$2 >= ${minor}))
			exit 0;
		else
			exit 1;
	}
CMAKE_VERSION_CHECK

	echo "${version}" | awk "$(< "${version_check_awk_script}")"
}

it_has_modern_ccache() {
	# ccache 2.x only supported short options
	ccache --version
}

it_has_ninja_17() {
	local ninja_version
	readonly ninja_version=$(ninja --version)

	check_version_major_minor "${ninja_version}" 1 7
}

it_has_executables() {
	local EXECUTABLES=(
		vim
		make
		patch
		bzip2
		unzip
		pigz
		xz
		wget
		ip
	)
	for executable in "${EXECUTABLES[@]}"; do
		type -p "${executable}"
	done
}

it_has_python_modules_visible_to_every_user() {
	local -a PYTHON_MODULES=(
	psutil
	lockfile
	paramiko
	epydoc
	)

	local module
	for module in "${PYTHON_MODULES[@]}"; do
		python -c "import ${module}"
	done
}

_main "$@"
