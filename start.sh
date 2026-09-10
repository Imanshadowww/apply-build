#!/bin/sh

# رمز عبور شما (UUID)
UUID="d342d11e-d424-4583-b36e-524ab1f0afa4"

# ساخت تنظیمات هسته Xray
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

# ساخت تنظیمات وب‌سرور Nginx (بدون شرط سخت‌گیرانه برای عبور راحت‌تر ترافیک)
cat <<EOF > /etc/nginx/http.d/default.conf
server {
    listen 8000;
    
    location / {
        add_header Content-Type "text/plain; charset=utf-8";
        return 200 "Server is Healthy and Running!";
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
# ساخت پوشه موقت برای جلوگیری از کرش کردن Nginx
mkdir -p /run/nginx
nginx -g 'daemon off;'
