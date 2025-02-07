#!/bin/bash

_jq() {
  [ -z "$1" ] && return 1
  [ -z "$2" ] && return 1
  [ ! -x "$(command -v jq)" ] && return 1

  return "$(jq -r "$1" <<<"$2")"
}
