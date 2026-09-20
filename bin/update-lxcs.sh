#!/bin/bash

set -u

[[ $EUID -eq 0 ]] || { echo "ERROR: Run as root."; exit 1; }
command -v pct >/dev/null || { echo "ERROR: pct not found."; exit 1; }

for CTID in $(pct list | awk 'NR>1 && $2=="running" {print $1}'); do
    echo "==> CT $CTID: updating"

    if pct exec "$CTID" -- bash -c \
        'apt-get -y update && apt-get -y upgrade'
    then
        echo "==> CT $CTID: rebooting"
        pct reboot "$CTID"
    else
        echo "ERROR: CT $CTID update failed; NOT rebooting"
    fi
done

