variable "vpc_name" {
  description = "The name of vpc"
}

variable "cidr_block" {
  description = "The didr block of vpcß"
}

variable "availability_zone" {
  type = list(string)
  description = "az of subnet"
}

variable "subnets" {
  type = map(object({
    cidr_block = string
    availability_zone = string
    nat_gateway_subnet = optional(string)
  }))
}

variable "security_groups" {
  description = "map of security group with rules"

  type = map(object({
    ingress_rules = list(object({
      from_port = number
      to_port = number
      protocol = string
      cidr_blocks = list(string)
    }))
    egress_rules = list(object({
      from_port = number
      to_port = number
      protocol = string
      cidr_blocks = list(string)
    }))
  }))
}