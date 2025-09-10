#!/bin/sh
set -ex
: "${PORT:=8080}"  # ensure PORT

# render nginx conf from template
envsubst '${PORT} ${VLESS_PATH}' \
  < /etc/nginx/http.d/default.conf.tpl \
  > /etc/nginx/http.d/default.conf

# show final conf (debug in logs)
echo "---- /etc/nginx/http.d/default.conf ----"
cat /etc/nginx/http.d/default.conf

# override xray settings from env
if [ -n "${UUID}" ]; then
  sed -i 's#"id": ".*"#"id": "'"${UUID}"'"#' /etc/xray/config.json
fi
if [ -n "${VLESS_PATH}" ]; then
  sed -i 's#"path": "/[^"]*"#"path": "/'"${VLESS_PATH}"'"#' /etc/xray/config.json
fi

echo "[entrypoint] PORT=${PORT} VLESS_PATH=${VLESS_PATH} UUID=${UUID}"

# optional: config test (won't stop boot)
nginx -t || true

exec /usr/bin/supervisord -c /etc/supervisord.conf
