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

sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql/data/postgresql.conf
echo "host all all 0.0.0.0/0 md5" >> /var/lib/pgsql/data/pg_hba.conf

systemctl restart postgresql-15


SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "postgres-credentials" \
  --query SecretString \
  --output text)

DB_USERNAME=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')

sudo -u postgres psql -d postgres <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DB_USERNAME') THEN
      CREATE ROLE $DB_USERNAME LOGIN PASSWORD '$DB_PASSWORD';
   END IF;
END
\$\$;

CREATE DATABASE ec2db OWNER $DB_USERNAME;
GRANT ALL PRIVILEGES ON DATABASE ec2db TO $DB_USERNAME;
EOF

echo "<h1>nginx + PostgreSQL running via Secrets Manager!</h1>" \
  > /usr/share/nginx/html/index.html
