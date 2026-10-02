output "vpc_id" {
  value = aws_vpc.main.id
}

output "internet_gateway_id" {
  value = var.create_internet_gateway ? aws_internet_gateway.igw[0].id : null
}

output "subnet_ids" {
  value = {
    for name, subnet in aws_subnet.subnet :
      name => subnet.id
  }
}

output "route_table_ids" {
  value = {
    for name, rt in aws_route_table.route_table :
      name => rt.id
  }
}

output "nat_gateway_ids" {
  value = {
    for name, natgw in aws_nat_gateway.natgw :
      name => natgw.id
  }
}

output "nat_eip_ids" {
  value = {
    for name, eip in aws_eip.nat :
      name => eip.id
  }
}