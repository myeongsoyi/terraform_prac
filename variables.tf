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