FROM python:3.11-slim

WORKDIR /app

# نصب گیت برای دریافت کدهای پنل
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# دانلود سورس پنل از گیت‌هاب اصلی
RUN git clone https://github.com/arvin341az-glitch/RVG.git .

# نصب پیش‌نیازهای پایتون
RUN pip install --no-cache-dir -r requirements.txt

# معرفی دامنه سایت شما به پنل و تنظیم پورت
ENV RAILWAY_PUBLIC_DOMAIN=imann.apps.apply.build
ENV PORT=8000

# اجرای سرور پنل
CMD ["python", "main.py"]
