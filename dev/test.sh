#!/bin/bash -e

pushd $1
drpcli contents bundle $1.yaml
drpcli contents destroy $1 || true
drpcli contents create $1.yaml
