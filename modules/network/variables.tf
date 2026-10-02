variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.123.0.0/16"
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "JhaVPC"
}

variable "igw_name" {
  description = "Name of IGW"
  type        = string
  default     = "JhaIGW"
}

variable "create_internet_gateway" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT Gateway"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "VPC에서 사용할 Availability Zones"
  type        = list(string)
  default     = [ "ap-northeast-2a", "ap-northeast-2c", "ap-northeast-2b", "ap-northeast-2d" ]
}