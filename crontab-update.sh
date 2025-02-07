#!/bin/bash

TMP_EPX_PATH="/opt/epx"

cd "$TMP_EPX_PATH" || return

git reset --hard HEAD
git pull

cd - || return
