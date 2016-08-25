#!/bin/bash

# this is so hard
source /etc/profile

set -e -u -o pipefail

/bin/bash --rcfile /workspace/bug-free-fortnight/streamline-master/db_shell_bashrc.bash
