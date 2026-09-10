#!/bin/sh

UUID="d342d11e-d424-4583-b36e-524ab1f0afa4"

# ساخت فایل HTML واقعی برای تیک سبز سلامت
mkdir -p /var/www/html
echo "<html><body><h1>Server is Healthy and Running!</h1></body></html>" > /var/www/html/index.html

# ساخت تنظیمات Xray
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
            "network": "ws",
            "wsSettings": {"path": "/vless"}
        }
    }],
    "outbounds": [{"protocol": "freedom"}]
}
EOF

# ساخت تنظیمات استاندارد Nginx بدون شروط اضافه
cat <<EOF > /etc/nginx/http.d/default.conf
server {
    listen 8000;
    root /var/www/html;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    location /vless {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:8081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

echo "Starting Xray Core..."
/usr/local/bin/xray -c /config.json &

echo "Starting Nginx Web Server..."
mkdir -p /run/nginx
# چک کردن اینکه تنظیمات Nginx مشکل تایپی نداشته باشد
nginx -t
nginx -g 'daemon off;'
