#!/bin/sh

# این UUID همان پسورد شماست (می‌توانید بعداً عوضش کنید)
UUID="d342d11e-d424-4583-b36e-524ab1f0afa4"

# ۱. ساخت تنظیمات Xray (روی پورت مخفی 8081)
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

# ۲. ساخت تنظیمات Nginx (روی پورت اصلی 8000)
cat <<EOF > /etc/nginx/http.d/default.conf
server {
    listen 8000;
    
    # پاسخ سریع به سیستم Health Check میزبان
    location / {
        add_header Content-Type text/plain;
        return 200 "Server is Healthy and Running!";
    }
    
    # انتقال ترافیک VPN به Xray
    location /vless {
        if (\$http_upgrade != "websocket") {
            return 404;
        }
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
nginx -g 'daemon off;'
