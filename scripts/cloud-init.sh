#!/bin/bash

set -e

apt-get update -y
apt-get upgrade -y
apt-get install nginx -y

systemctl start nginx 


apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)

apt update -y
apt install ca-certificates curl
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

cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 80;
    listen [::]:80;
    root /var/www/html;
    index index.php index.html index.htm;
    server_name makariuz.xyz www.makariuz.xyz;
    
    location / {
        proxy_pass http://localhost:3000;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF