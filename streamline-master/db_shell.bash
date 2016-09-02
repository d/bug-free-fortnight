#!/bin/bash

set -e -u -o pipefail

cd "$(dirname $0)"
/bin/bash --rcfile db_shell_bashrc.bash
