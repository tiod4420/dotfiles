#!/usr/bin/env bash

DISK=${1:-/dev/nvme0n1p2}

systemd-cryptenroll --wipe-slot=tpm2 ${DISK}
RES=$?; [ 0 -ne $RES ] && exit 1

systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+1+2+3+4+5+7+8 ${DISK}
RES=$?; [ 0 -ne $RES ] && exit 1
