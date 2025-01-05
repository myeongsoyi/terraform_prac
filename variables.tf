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

variable "public_subnets" {
  type = list(object({
    name = string
    availability_zone = string
    cidr_block = string 
  }))
}