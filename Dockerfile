FROM alpine:3.20

# + gettext to get `envsubst`
RUN apk add --no-cache nginx supervisor curl unzip ca-certificates gettext \
    && update-ca-certificates

ENV XRAY_VERSION=1.8.23
RUN mkdir -p /usr/local/bin /etc/xray /var/log/xray \
 && curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-64.zip \
 && unzip -q /tmp/xray.zip -d /usr/local/bin \
 && rm -f /tmp/xray.zip \
 && chmod +x /usr/local/bin/xray

# ❗ Remove Alpine's stock conf that listens on :80
RUN rm -f /etc/nginx/http.d/default.conf

COPY xray-config.json /etc/xray/config.json
COPY nginx.conf.tpl /etc/nginx/http.d/default.conf.tpl
COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV VLESS_PATH="Telegram-@n4vpn"
ENV UUID="N4vpnpro-b88e-4229-9495-d5b5eeb23230"
ENV PORT=8080

RUN mkdir -p /run/nginx /var/www/html \
 && printf 'ok\n' > /var/www/html/health

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
