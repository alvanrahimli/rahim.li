#!/bin/bash

# https://miniflux.rahim.li/starred/entry/2904

read -p "Commit message: " desc
git add . && \
git commit -m "$desc" && \
git push

