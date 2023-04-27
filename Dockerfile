FROM nginx:mainline-alpine-slim

USER root
EXPOSE 80


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf
ADD entrypoint.sh /opt/entrypoint.sh


RUN apk add --no-cache ca-certificates curl unzip busybox supervisor


RUN curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL https://github.com/v2fly/v2ray-core/releases/download/v4.45.0/v2ray-linux-64.zip -o v2ray_dist.zip && \
    busybox unzip v2ray_dist.zip -d /usr/bin && \
    rm -rf v2ray_dist.zip

# Write V2Ray configuration
RUN mkdir -p /etc/v2ray && \
    cat << EOF > /tmp/heroku.json
{
    "inbounds": [{
        "port": 80,
        "protocol": "vmess",
        "settings": {
            "clients": [{
                "id": "98f3d58a-a53d-4662-9698-83e6ac172b47",
                "alterId": 64
            }]
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
                "path": "/"
            }
        }
    }],
    "outbounds": [{
        "protocol": "freedom"
    }]
}
EOF
RUN /usr/bin/v2ctl config /tmp/heroku.json > /etc/v2ray/config.pb


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf



# Start supervisord and V2Ray
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

