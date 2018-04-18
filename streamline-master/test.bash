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

	it_has_ninja_17_plus

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
	readonly cmake_version=$(cmake --version 2>/dev/null | sed 's/[^0-9]\+/ /g')
	local cmake_version_check
	readonly cmake_version_check=$(mktemp -t cmake_version_check.XXX.awk)

	cat > "${cmake_version_check}" << 'CMAKE_VERSION_CHECK'
	{
		if ($1 > 3 || ($1 == 3 && $2 >= 6))
			exit 0;
		else
			exit 1;
	}
CMAKE_VERSION_CHECK

	echo "${cmake_version}" | awk "$(< "${cmake_version_check}")"
}

it_has_modern_ccache() {
	# ccache 2.x only supported short options
	ccache --version
}

it_has_ninja_17_plus() {
	local ninja_version
	readonly ninja_version="$(ninja --version)"
	local major minor
	local IFS=.
	# the patch number is unused, but needs to be there to absorb the third
	# number
	read -r major minor _ <<< "${ninja_version}"
	if [ "${major}" -eq 1 ]; then
		if [ "${minor}" -ge 7 ]; then
			true
		else
			return 2
		fi
	else
		return 1
	fi
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
