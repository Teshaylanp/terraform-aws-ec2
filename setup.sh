#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

dnf update -y
dnf install -y jq awscli postgresql postgresql-server nginx

systemctl enable nginx
systemctl start nginx

postgresql-setup --initdb
systemctl enable postgresql
systemctl start postgresql

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "postgres-credentials" \
  --query SecretString \
  --output text)

DB_USERNAME=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')

sudo -u postgres psql <<EOF
CREATE USER $DB_USERNAME WITH PASSWORD '$DB_PASSWORD';
CREATE DATABASE ec2db OWNER $DB_USERNAME;
GRANT ALL PRIVILEGES ON DATABASE ec2db TO $DB_USERNAME;
EOF

echo "<h1>nginx + PostgreSQL running via Secrets Manager!</h1>" > /usr/share/nginx/html/index.html
