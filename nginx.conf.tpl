server {
    listen ${PORT};
    server_name _;

    # Health check
    location = / {
        default_type text/plain;
        return 200 "ok\n";
    }

    # VLESS WS path
    location /${VLESS_PATH} {
        proxy_redirect          off;
        proxy_pass              http://127.0.0.1:10000;
        proxy_http_version      1.1;
        proxy_set_header        Upgrade $http_upgrade;
        proxy_set_header        Connection "upgrade";
        proxy_set_header        Host $host;
        proxy_read_timeout      300s;
    }
}