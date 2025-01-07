locals {
    private_subnets = {
        for key, subnet in var.subnets :
        key => subnet
        if lookup(subnet, "nat_gateway_subnet", null) != null
    }
}

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

resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id = aws_vpc.main.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  map_public_ip_on_launch = lookup(each.value, "nat_gateway_subnet", null) != null ? false: true

  tags = {
    Name = each.key
  }
}

resource "aws_eip" "nat_ips" {
  for_each = local.private_subnets
}

resource "aws_nat_gateway" "gateways" {
  for_each = local.private_subnets

  allocation_id = aws_eip.nat_ips[each.key].id
  subnet_id = aws_subnet.subnets[each.value.nat_gateway_subnet].id
}