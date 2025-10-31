resource "aws_secretsmanager_secret" "database_credentials" {
  name = "database-credentials"
}

resource "aws_secretsmanager_secret_version" "database_credentials_version" {
  secret_id = aws_secretsmanager_secret.database_credentials.id
  secret_string = jsonencode({
    username = "ec2user"
    password = "StrongPassword123!"
  })
}
