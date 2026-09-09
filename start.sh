#!/bin/sh

# اجرای هسته‌ی تیل‌اسکیل در بک‌گراند (حالت یوزراسپیس)
tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --state=mem: &

sleep 3

# اتصال به اکانت تو با اصلاح مشکل DNS و اضافه کردن ephemeral
tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=my-custom-node --accept-routes --advertise-exit-node --accept-dns=false --ephemeral

# اجرای یک وب‌سایت فیک روی پورتی که سایت میزبان میخواد تا سرور رو خاموش نکنه
echo "Tailscale is running! Starting dummy web server..."
python3 -m http.server ${PORT:-8080}
