#!/bin/bash

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci chattr

chattr +i "$@"
