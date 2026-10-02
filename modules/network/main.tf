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

# Subnet(Public)
resource "aws_subnet" "public" {
  count = 2

  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.vpc_name}-public-subnet${count.index + 1}"
  }
}

# Subnet(Private)
resource "aws_subnet" "private" {
  count = 2

  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 10 + count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.vpc_name}-private-subnet${count.index + 1}"
  }
}

# Routing Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table" "private" {
  count = length(aws_subnet.private)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-private-rt${count.index + 1}"
  }
}

# RouteTableAssociation
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Route(Public)
resource "aws_route" "public_internet" {
  count = var.create_internet_gateway ? 1 : 0

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

# Elastic IP
resource "aws_eip" "nat_eip" {
  count = var.create_internet_gateway ? length(aws_subnet.public) : 0

  domain = "vpc" # default

  tags = {
    Name = "${var.vpc_name}-nat-eip${count.index + 1}"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "natgw" {
  count = var.create_internet_gateway ? length(aws_subnet.public) : 0

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.vpc_name}-natgw${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Route(private)
resource "aws_route" "private_nat" {
  count = var.create_internet_gateway ? length(aws_subnet.private) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[count.index].id
}
