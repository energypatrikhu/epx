#!/bin/bash

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci ufw

ufw status numbered
