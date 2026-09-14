FROM python:3.11-slim

WORKDIR /app

# نصب پیش‌نیازها و وب‌سرور Nginx
RUN apt-get update && apt-get install -y git nginx && rm -rf /var/lib/apt/lists/*

# دانلود سورس پنل از گیت‌هاب اصلی
RUN git clone https://github.com/arvin341az-glitch/RVG.git .

# نصب پیش‌نیازهای پایتون
RUN pip install --no-cache-dir -r requirements.txt

# تنظیمات Nginx برای گرفتن قطعی تیک سبز و عبور ترافیک پنل
RUN echo 'server { \
    listen 8000; \
    location = /health { \
        add_header Content-Type text/plain; \
        return 200 "OK"; \
    } \
    location / { \
        proxy_pass http://127.0.0.1:8081; \
        proxy_http_version 1.1; \
        proxy_set_header Upgrade $http_upgrade; \
        proxy_set_header Connection "upgrade"; \
        proxy_set_header Host imann.apps.apply.build; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
    } \
}' > /etc/nginx/sites-available/default

# تنظیم متغیرها (روی 8081 اجرا می‌شود و Nginx روی 8000)
ENV RAILWAY_PUBLIC_DOMAIN=imann.apps.apply.build
ENV PORT=8081

# اجرای همزمان Nginx و سرور پایتون
CMD service nginx start && python main.py
