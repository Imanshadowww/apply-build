#!/bin/sh

UUID="d342d11e-d424-4583-b36e-524ab1f0afa4"

# ساخت فایل HTML برای عبور از Health Check
mkdir -p /var/www/html
echo "<html><body><h1>Server is Healthy and Running!</h1></body></html>" > /var/www/html/index.html

# تنظیمات Xray با پروتکل فوق‌مخفی SplitHTTP
cat <<EOF > /config.json
{
    "inbounds": [{
        "port": 8081,
        "listen": "127.0.0.1",
        "protocol": "vless",
        "settings": {
            "clients": [{"id": "$UUID"}],
            "decryption": "none"
        },
        "streamSettings": {
            "network": "splithttp",
            "splithttpSettings": {
                "path": "/vless"
            }
        }
    }],
    "outbounds": [{"protocol": "freedom"}]
}
EOF

# تنظیمات Nginx با خاموش کردن بافرینگ (بسیار مهم برای عبور ترافیک تکه‌تکه)
cat <<EOF > /etc/nginx/http.d/default.conf
server {
    listen 8000;
    root /var/www/html;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    location /vless {
        proxy_pass http://127.0.0.1:8081;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        # خاموش کردن بافرینگ برای عبور درلحظه ترافیک VPN
        proxy_buffering off;
        proxy_request_buffering off;
    }
}
EOF

echo "Starting Xray Core..."
/usr/local/bin/xray -c /config.json &

echo "Starting Nginx Web Server..."
mkdir -p /run/nginx
nginx -t
nginx -g 'daemon off;'
