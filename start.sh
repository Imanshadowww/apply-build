#!/bin/sh

# اول از همه وب‌سرور را روی پورت 8000 در پس‌زمینه روشن می‌کنیم تا پنل ارور ندهد
echo "Starting dummy web server on port 8000..."
python3 -m http.server 8000 &

# حالا هسته‌ی تیل‌اسکیل را اجرا می‌کنیم
tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --state=mem: &
sleep 3

# و در نهایت به اکانت متصل می‌شویم
tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=Apply-Node --advertise-exit-node --accept-dns=false --ephemeral

# این دستور باعث می‌شود کانتینر بیدار بماند و خاموش نشود
wait
