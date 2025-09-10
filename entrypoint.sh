#!/bin/sh
set -e

# Apply env to nginx conf
envsubst '${PORT} ${VLESS_PATH}' < /etc/nginx/http.d/default.conf.tpl > /etc/nginx/http.d/default.conf

# Optionally override UUID/Path in Xray config from envs
if [ -n "${UUID}" ]; then
  sed -i "s#\"id\": \".*\"#\"id\": \"${UUID}\"#g" /etc/xray/config.json
fi
if [ -n "${VLESS_PATH}" ]; then
  sed -i "s#\"path\": \"/[^\"]*\"#\"path\": \"/${VLESS_PATH}\"#g" /etc/xray/config.json
fi

# Show effective settings
echo "[entrypoint] PORT=${PORT} VLESS_PATH=${VLESS_PATH} UUID=${UUID}"

# Start supervisor (nginx + xray)
exec /usr/bin/supervisord -c /etc/supervisord.conf