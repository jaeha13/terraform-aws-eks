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

variable "create_internet_gateway" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = true
}

variable "subnets" {
  description = "The list of Subnets"
  type = list(object({
    name                          = string
    cidr_block                    = string
    availability_zone             = string
    route_table                   = string
    map_public_ip_on_launch       = optional(bool, false)
    private_dns_hostname_type_on_launch = optional(string, "ip-name")
    enable_dns64                  = optional(bool, false)
  }))
  default = [{
    name = "subnet01"
    cidr_block = "10.123.1.0/24"
    availability_zone = "ap-northeast-2a"
    route_table = "subnet01-rt"
  }]
}

variable "route_tables" {
  description = "The list of RouteTables"
  type = list(object({
    name = string
  }))
  default = [{
    name = "subnet01-rt"
    }]
}

variable "routes" {
  description = "The list of routes"
  type = list(object({
    route_table = string
    destination = string
    target_type = string
    target      = optional(string)
  }))
  default = [{
    route_table = "subnet01-rt"
    destination = "0.0.0.0/0"
    target_type = "internet_gateway"
    target = "igw"
  }]

  validation {
    condition = alltrue([
      for route in var.routes :
      contains(["internet_gateway", "nat_gateway"], route.target_type)
    ])

    error_message = "target_type must be either 'internet_gateway' or 'nat_gateway'."
  }

  validation {
  condition = alltrue([
    for route in var.routes :
    route.target_type == "internet_gateway"
    || (
      route.target_type == "nat_gateway"
      && route.target != null
    )
  ])

  error_message = "nat_gateway routes must specify target."
  }
}

variable "nat_gateways" {
  description = "The list of NatGateway"
  type        = list(object({
    name = string
    subnet = string
  }))
  default = [{
    name = "natgw"
    subnet = "subnet01"
  }]
}

# variable "availability_zones" {
#   description = "VPC에서 사용할 Availability Zones"
#   type        = list(string)
#   default     = [ "ap-northeast-2a", "ap-northeast-2c", "ap-northeast-2b", "ap-northeast-2d" ]
# }