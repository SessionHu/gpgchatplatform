#!/bin/bash

resp=`mktemp`

if [[ "$REQUEST_METHOD" == "OPTIONS" ]]; then
  echo "$SERVER_PROTOCOL 204 No Content"
elif [[ "$REQUEST_METHOD" != "POST" ]]; then
  cat > $resp << EOF
Method not allowed
EOF
  echo "$SERVER_PROTOCOL 405 Method Not Allowed"
elif grep -vqE '^[0-9A-Z]{40}$' <<< "$HTTP_X_SGCC_TO"; then
  cat > $resp << EOF
X-SGCC-To in header fields is not PGP key fingerprint
EOF
  echo "$SERVER_PROTOCOL 400 Bad Request"
elif [[ -n "$CONTENT_TYPE" ]] && [[ "$CONTENT_TYPE" != "application/octet-stream" ]] && [[ "$CONTENT_TYPE" != 'text/plain' ]] && [[ "$CONTENT_TYPE" != "application/pgp-encrypted" ]]; then
  echo "$SERVER_PROTOCOL 415 Unsupported Media Type"
  cat > $resp << EOF
Content-Type in header fields is not supported
EOF
elif [[ "$HTTP_CONTENT_LENGTH" -gt 1024 ]]; then
  echo "$SERVER_PROTOCOL 413 Request Entity Too Large"
  cat > $resp << EOF
Content-Length in header fields is too large (>1024 bytes)
EOF
else
  boxpath="../../data/box/$HTTP_X_SGCC_TO"
  msgid=`date +%s%N`
  datapath="${boxpath}/${msgid}.gpg"
  tmpf=`mktemp`
  gpg --batch --no-tty --dearmor <&0 --output "$tmpf" 2>$resp
  if [[ $? -ne 0 ]]; then
    echo "$SERVER_PROTOCOL 500 Internal Server Error"
    rm $tmpf
  else
    mkdir -p "$boxpath"
    mv "$tmpf" "$datapath"
    echo "$msgid" > $resp
  fi
fi

cat - $resp << EOF
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type, X-SGCC-To
Access-Control-Max-Age: 86400
Allow: OPTIONS, POST
Server: $SERVER_SOFTWARE $GATEWAY_INTERFACE (sgcc)
Date: $(date -u "+%a, %d %b %Y %T GMT")
Content-Type: text/plain
Content-Length: `stat --format=%s $resp`

EOF

rm $resp
