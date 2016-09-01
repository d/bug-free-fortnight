#!/bin/bash

set -e -u -o pipefail

USER="$(id -un)"
LOGNAME="${USER}"
export USER LOGNAME


/bin/bash --rcfile /workspace/bug-free-fortnight/streamline-master/db_shell_bashrc.bash
