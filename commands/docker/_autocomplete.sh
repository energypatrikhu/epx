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

_d_autocomplete_templates() {
  local available_templates="$(find "$EPX_PATH/.templates/docker/dockerfile" -maxdepth 1 -type f -name '*.template' -exec basename {} .template \; | tr '\n' ' ')"
  _autocomplete "$available_templates"
}
