resource "aws_secretsmanager_secret" "database_credentials_postgres_final" {
  name = "database-credentials-neww"
}

resource "aws_secretsmanager_secret_version" "database_credentials_version" {
  secret_id = aws_secretsmanager_secret.database_credentials_postgres_final.id
  secret_string = jsonencode({
    username = "ec2user"
    password = "StrongPassword123!"
  })
}
