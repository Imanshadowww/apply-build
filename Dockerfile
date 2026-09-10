FROM alpine:latest

# نصب پیش‌نیازها و وب‌سرور انجینکس
RUN apk update && apk add nginx curl unzip

# دانلود و نصب آخرین نسخه هسته Xray
RUN curl -L -H "Cache-Control: no-cache" -o xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm xray.zip

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
