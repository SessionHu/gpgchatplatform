#!/bin/sh
port="$1"
[ -z "$1" ] && port=8080
exec busybox httpd -vvfh "`dirname $0`/server" -p $port
