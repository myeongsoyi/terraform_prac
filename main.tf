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

resource "aws_route_table" "route_tables" {
  for_each = var.subnets
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${each.key}-route-table"
  }
}

resource "aws_route" "routes" {
  for_each = var.subnets

  route_table_id = aws_route_table.route_tables[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = lookup(each.value, "nat_gateway_subnet", null) == null ? aws_internet_gateway.main.id : null
  nat_gateway_id = lookup(each.value, "nat_gateway_subnet", null) != null ? aws_nat_gateway.gateways[each.key].id : null
}

resource "aws_route_table_association" "associattions" {
  for_each = var.subnets

  subnet_id = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.route_tables[each.key].id
}

resource "aws_security_group" "groups" {
  for_each = var.security_groups

  name = each.key
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
     from_port = ingress.value.from_port
     to_port = ingress.value.to_port
     protocol = ingress.value.protocol
     cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = each.value.egress_rules
    content {
     from_port = egress.value.from_port
     to_port = egress.value.to_port
     protocol = egress.value.protocol
     cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = each.key
  }
}