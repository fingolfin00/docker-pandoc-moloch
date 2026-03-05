#!/usr/bin/env bash

docker build . \
  --build-arg PANDOC_THEMES_REF=$(git ls-remote https://github.com/fingolfin00/pandoc-themes.git HEAD | cut -f1) \
  -t pandoc/extra-moloch --pull # --no-cache
