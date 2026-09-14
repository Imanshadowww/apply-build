FROM alpine:latest
RUN apk add --no-cache curl wget unzip tailscale

RUN wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip -d /usr/local/bin/ && chmod +x /usr/local/bin/xray && rm xray.zip

COPY config.json /etc/xray/config.json

RUN echo '#!/bin/sh' > /run.sh && \
    echo 'tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &' >> /run.sh && \
    echo 'sleep 3' >> /run.sh && \
    echo 'tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=apply-build-app --exit-node=100.71.174.19 --accept-routes' >> /run.sh && \
    echo 'xray -config /etc/xray/config.json' >> /run.sh && \
    chmod +x /run.sh

CMD ["/run.sh"]
