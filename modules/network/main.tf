# VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default" # default : 하드웨어 공유 / dedicated : 해당 서버는 나만 사용 / host : 해당 서버는 나만 사용하고 내가 관리 

  tags = {
    Name = var.vpc_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  count = var.create_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Subnet
resource "aws_subnet" "subnet" {
  for_each = {
    for subnet in var.subnets :
    subnet.name => subnet
  }

  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone

  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  private_dns_hostname_type_on_launch = (
    each.value.private_dns_hostname_type_on_launch
  )

  enable_dns64 = each.value.enable_dns64

  tags = {
    Name = "${var.vpc_name}-${each.key}"
  }
}

# Routing Table
resource "aws_route_table" "route_table" {
  for_each = {
    for rt in var.route_tables :
      rt.name => rt
  }

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-${each.key}"
  }
}

# RouteTableAssociation
resource "aws_route_table_association" "route_table_association" {
  for_each = {
    for subnet in var.subnets :
    subnet.name => subnet
  }

  subnet_id = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.route_table[
    each.value.route_table
  ].id
}

# Route
resource "aws_route" "route" {
  for_each = {
    for route in var.routes :
    "${route.route_table}-${route.destination}-${route.target}" => route
  }

  route_table_id = aws_route_table.route_table[each.value.route_table].id

  destination_cidr_block = each.value.destination
  
  # Internet Gateway
  gateway_id = (each.value.target_type == "internet_gateway" && var.create_internet_gateway
    ? aws_internet_gateway.igw[0].id
    : null
  )

  # NAT Gateway
  nat_gateway_id = (each.value.target_type == "nat_gateway"
    ? aws_nat_gateway.natgw[each.value.target].id
    : null
  )
}

# Elastic IP
resource "aws_eip" "nat" {
  for_each = {
    for natgw in var.nat_gateways :
    natgw.name => natgw
  }

  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-${each.key}-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "natgw" {
  for_each = {
    for natgw in var.nat_gateways :
    natgw.name => natgw
  }

  allocation_id = aws_eip.nat[each.key].id

  subnet_id = aws_subnet.subnet[
    each.value.subnet
  ].id

  tags = {
    Name = "${var.vpc_name}-${each.key}-natgw"
  }
}