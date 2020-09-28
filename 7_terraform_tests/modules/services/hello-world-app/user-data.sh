#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
yum update -y
wget https://www.busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64
chmod +x busybox-x86_64
mv busybox-x86_64 /usr/local/bin/busybox
cat > index.html <<EOF
<h1>${server_text}</h1>
<p>DB Address: ${db_address}</p>
<p>DB Port: ${db_port}</p>
EOF
nohup busybox httpd -f -p ${server_port} &