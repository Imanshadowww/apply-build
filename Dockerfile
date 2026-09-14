FROM alpine:latest

# نصب ابزارهای مورد نیاز و تیل‌اسکیل
RUN apk add --no-cache curl wget unzip tailscale

# دانلود و نصب آخرین نسخه هسته Xray
RUN wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm xray.zip

# کپی کردن فایل‌ها به داخل کانتینر
COPY config.json /etc/xray/config.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# استارت کانتینر
CMD ["/entrypoint.sh"]
