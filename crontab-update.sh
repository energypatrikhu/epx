#!/bin/bash

TMP_EPX_PATH="/opt/epx"

cd "$TMP_EPX_PATH" || return

git pull

cd - || return
