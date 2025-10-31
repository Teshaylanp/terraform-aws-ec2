resource "aws_security_group" "web_traffic" {
  name        = "allow_web_nginx"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_web_nginx"
  }

}

resource "aws_eip" "nginx_server_eip" {
  instance = aws_instance.nginx-postgres-ec2.id
  tags = {
    Name = "nginx_server_eip"
  }
}

resource "aws_instance" "nginx-postgres-ec2" {
  ami                    = "ami-0f9fa7cd5a3697470"
  instance_type          = "t3.micro"
  key_name               = local.keyname
  availability_zone      = local.azone1
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.web_traffic.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  user_data_base64       = filebase64("${path.module}/setup.sh")

  tags = {
    Name = "nginx-postgres-ec2"
    Role = "web-db"
  }
}

output "nginx_public_ip" {
  value = aws_eip.nginx_server_eip.public_ip
}

output "nginx_instance_id" {
  value = aws_instance.nginx-postgres-ec2.id
}
