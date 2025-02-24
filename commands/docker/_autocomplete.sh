#!/bin/bash

_d_autocomplete() {
  _autocomplete "$(docker ps -a --format '{{.Names}}')"
}

_d_autocomplete_all() {
  _autocomplete "all $(docker ps -a --format '{{.Names}}')"
}

_d_autocomplete_list() {
  _autocomplete "created restarting running removing paused exited dead"
}
