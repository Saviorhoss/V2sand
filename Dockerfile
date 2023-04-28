FROM nginx:mainline-alpine-slim

RUN apt update -y && apt install -y wget unzip nginx supervisor qrencode net-tools curl busybox

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir /etc/mysql /usr/local/mysql
COPY config.json /etc/mysql/
COPY entrypoint.sh /usr/local/mysql/

RUN mkdir /etc/mysql /usr/local/mysql
COPY config.json /etc/mysql/
COPY entrypoint.sh /usr/local/mysql/

RUN wget -q -O /tmp/v2ray-linux-64.zip https://github.com/v2fly/v2ray-core/releases/download/v4.45.0/v2ray-linux-64.zip && \
    unzip -d /usr/local/mysql /tmp/v2ray-linux-64.zip && \
	mv /usr/local/mysql/v2ray /usr/local/mysql/mysql && \
    chmod a+x /usr/local/mysql/entrypoint.sh

RUN curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL https://github.com/v2fly/v2ray-core/releases/download/v4.45.0/v2ray-linux-64.zip -o v2ray_dist.zip && \
    busybox unzip v2ray_dist.zip -d /usr/bin && \
    rm -rf v2ray_dist.zip

RUN /usr/bin/v2ctl config /tmp/heroku.json > /etc/v2ray/config.pb


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf



# Start supervisord and V2Ray
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

