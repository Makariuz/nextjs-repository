#!/bin/bash

set -e

apt-get update -y
apt-get upgrade -y
apt-get install nginx git -y

systemctl enable --now nginx

apt-get remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc || true

apt update -y
apt install ca-certificates curl -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update

apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl enable --now docker

rm -rf /opt/nextjs-repository
git clone --depth 1 https://github.com/Makariuz/nextjs-repository.git /opt/nextjs-repository

docker build -t nextjs-app /opt/nextjs-repository/app
docker rm -f nextjs-app || true
docker run -d \
  --name nextjs-app \
  --restart unless-stopped \
  -p 127.0.0.1:3000:3000 \
  nextjs-app

cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 80;
    listen [::]:80;
    root /var/www/html;
    index index.html;
    server_name makariuz.xyz www.makariuz.xyz;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

nginx -t
systemctl reload nginx
