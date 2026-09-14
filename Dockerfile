FROM alpine:latest

RUN apk add --no-cache unzip wget curl

RUN wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm xray.zip

COPY config.json /etc/xray/config.json

CMD ["xray", "-config", "/etc/xray/config.json"]
