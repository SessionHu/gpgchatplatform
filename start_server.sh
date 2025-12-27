#!/bin/sh
port="$1"
[ -z "$1" ] && port=8080
export LC_ALL=C
exec busybox httpd -vvfh "`dirname $0`/server" -p $port
