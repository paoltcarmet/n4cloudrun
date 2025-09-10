FROM alpine:3.20

# Install deps: nginx, supervisor, curl, unzip
RUN apk add --no-cache nginx supervisor curl unzip ca-certificates && update-ca-certificates

# Install Xray (static build)
ENV XRAY_VERSION=1.8.23
RUN mkdir -p /usr/local/bin /etc/xray /var/log/xray \
 && curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-64.zip \
 && unzip -q /tmp/xray.zip -d /usr/local/bin \
 && rm -f /tmp/xray.zip \
 && chmod +x /usr/local/bin/xray

# Copy configs & entrypoint
COPY xray-config.json /etc/xray/config.json
COPY nginx.conf.tpl /etc/nginx/http.d/default.conf.tpl
COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Runtime envs
ENV VLESS_PATH="Telegram-@n4vpn"
ENV UUID="N4vpnpro-b88e-4229-9495-d5b5eeb23230"
# Cloud Run will inject PORT; default to 8080 for local runs
ENV PORT=8080

# Nginx dirs
RUN mkdir -p /run/nginx /var/www/html \
 && printf 'ok\n' > /var/www/html/health

# Expose for local (Cloud Run uses $PORT)
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]