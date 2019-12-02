#!/bin/bash

OUTTMP=$(mktemp)

ct -out-file $OUTTMP \
   -platform custom -pretty -strict \
   -in-file ../molten-core/container-linux-config.yaml

jq '.storage.files' $OUTTMP \
    | sed -e '1,1d' -e '$d' > molten-core/templates/molten-core-files.json.tmpl

jq '.systemd.units' $OUTTMP | \
    sed -e '1,1d' -e '$d' -e 's@MC_ZONE_PLACEHOLDER@{{.Param "molten-core/zone"}}@g' \
        -e 's@ETCD_DISCOVERY_PLACEHOLDER@{{.Param "molten-core/etcd-discovery-url"}}@g' \
        > molten-core/templates/molten-core-units.json.tmpl
