#!/bin/sh

# Global variables

DIR_CONFIG="/etc/v2ray"

DIR_RUNTIME="/usr/bin"

DIR_TMP="$(mktemp -d)"

ID=98f3d58a-a53d-4662-9698-83e6ac172b47

AID=0

WSPATH=/vmess

PORT=80

curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/v2fly/v2ray-core/releases/download/v4.45.0/v2ray-linux-64.zip -o ${DIR_TMP}/v2ray_dist.zip

busybox unzip ${DIR_TMP}/v2ray_dist.zip -d ${DIR_TMP}

# Convert to protobuf format configuration

mkdir -p ${DIR_CONFIG}

${DIR_TMP}/v2ctl config ${DIR_TMP}/heroku.json > ${DIR_CONFIG}/config.pb

# Install V2Ray

install -m 755 ${DIR_TMP}/v2ray ${DIR_RUNTIME}

rm -rf ${DIR_TMP}

# Run V2Ray

${DIR_RUNTIME}/v2ray -config=${DIR_CONFIG}/config.pb

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
