resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.azone1

  tags = {
    Name = "${local.env}--private--${local.azone1}"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = local.azone2

  tags = {
    Name = "${local.env}--private--${local.azone2}"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = local.azone1
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${local.env}--public--${local.azone1}"
  }

}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = local.azone2
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${local.env}--public--${local.azone2}"
  }

}
