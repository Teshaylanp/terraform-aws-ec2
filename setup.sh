#!/bin/bash
#cloud-config
set -xe

dnf update -y

dnf install -y nginx
systemctl enable nginx
systemctl start nginx

echo "EC2 Nginx and PostGresSQL" > /usr/share/nginx/html/index.html

dnf install -y postgresql15 postgresql15-server

/usr/bin/postgresql-setup --initdb

systemctl enable postgresql
systemctl start postgresql

sudo -u postgres psql <<EOF
CREATE USER ec2user WITH PASSWORD 'password123';
CREATE DATABASE ec2db OWNER ec2user;
GRANT ALL PRIVILEGES ON DATABASE ec2db TO ec2user;
EOF

sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql/data/postgresql.conf
echo "host all all 0.0.0.0/0 md5" >> /var/lib/pgsql/data/pg_hba.conf

systemctl restart postgresql

if command -v firewall-cmd &>/dev/null; then
  firewall-cmd --add-service=http --permanent
  firewall-cmd --add-service=postgresql --permanent
  firewall-cmd --reload
fi
