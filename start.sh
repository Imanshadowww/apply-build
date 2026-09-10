#!/bin/sh

UUID="d342d11e-d424-4583-b36e-524ab1f0afa4"

# ساخت فایل HTML برای تیک سبز سلامت
mkdir -p /var/www/html
echo "<html><body><h1>Server is Healthy and Running!</h1></body></html>" > /var/www/html/index.html

# ساخت تنظیمات Xray بر پایه پروتکل قدرتمند gRPC
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
            "network": "grpc",
            "grpcSettings": {
                "serviceName": "vless"
            }
        }
    }],
    "outbounds": [{"protocol": "freedom"}]
}
EOF

# ساخت تنظیمات Nginx با پشتیبانی از HTTP/2 و gRPC
cat <<EOF > /etc/nginx/http.d/default.conf
server {
    listen 8000;
    http2 on;
    root /var/www/html;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    location /vless {
        grpc_pass grpc://127.0.0.1:8081;
        grpc_set_header X-Real-IP \$remote_addr;
    }
}
EOF

echo "Starting Xray Core..."
/usr/local/bin/xray -c /config.json &

echo "Starting Nginx Web Server..."
mkdir -p /run/nginx
nginx -t
nginx -g 'daemon off;'
