#!/bin/sh

echo "Starting dummy web server on port 8000..."
python3 -m http.server 8000 &

tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --state=mem: &
sleep 3

tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=Apply-Node --advertise-exit-node --accept-dns=false

wait
