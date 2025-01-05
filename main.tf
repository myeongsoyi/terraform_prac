resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  depends_on = [ aws_vpc.main ] # 명시적 의존성

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_subnet" "public" {
  count = length(var.availability_zone)
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.cidr_block, 8, count.index+1)
  availability_zone = "us-east-1${var.availability_zone[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-subnet-${var.availability_zone[count.index]}"
  }
}