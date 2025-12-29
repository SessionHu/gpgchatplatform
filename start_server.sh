#!/bin/sh
port="$1"
[ -z "$1" ] && port=8080
export LC_ALL=C
exec busybox httpd -vvfh "`dirname $0`/server" -p "$port" &
HTTPD_PID=$!
trap 'kill -TERM "$HTTPD_PID"' TERM INT
if [ "$CFTOKEN" ]; then
  exec cloudflared tunnel run --token "$CFTOKEN" &
  CFD_PID=$!
  trap 'kill -TERM "$CFD_PID"' TERM INT
  wait "$CFD_PID"
fi
wait "$HTTPD_PID"
