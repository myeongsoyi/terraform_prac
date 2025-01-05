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