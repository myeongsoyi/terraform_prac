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