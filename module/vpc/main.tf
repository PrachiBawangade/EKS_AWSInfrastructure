resource "aws_vpc" "vpc" {
    cidr_block       = var.vpc_id
    instance_tenancy = var.instance_tenancy
    enable_dns_support = var.enable_dns_support
    enable_dns_hostnames = var.enable_dns_hostnames
    assign_generated_ipv6_cidr_block = true  # Enable IPv6
    
    tags = {
        Name = "GreenEnco_VPC_Mumbai"
    }
}

# Get VPC's IPv6 CIDR Block
data "aws_vpc" "vpc" {
  id = aws_vpc.vpc.id
}

resource "aws_subnet" "public_01" {
  vpc_id            = aws_vpc.vpc.id  # Replace with your VPC ID
  cidr_block        = var.public_subnet_01   # Replace with your desired CIDR block
  availability_zone = var.availability_zone # Replace with your desired Availability Zone
  map_public_ip_on_launch = var.map_public_ip_on_launch           # Enable auto-assign public IP
  ipv6_cidr_block   = cidrsubnet(data.aws_vpc.vpc.ipv6_cidr_block, 8, 1)  # Assign an IPv6 range
  assign_ipv6_address_on_creation = true  # Enable automatic IPv6 assignment

  # Optional: Assign tags to your subnets
  tags = {
    Name = "GreenEnco_Public Subnet-01"
  }
}

# resource "aws_subnet" "public_02" {
#   vpc_id            = aws_vpc.vpc.id  # Replace with your VPC ID
#   cidr_block        = var.public_subnet_02  # Replace with your desired CIDR block
#   availability_zone = var.availability_zone1 # Replace with your desired Availability Zone
#   ipv6_cidr_block   = cidrsubnet(data.aws_vpc.vpc.ipv6_cidr_block, 8, 2)  # Assign an IPv6 range
#   assign_ipv6_address_on_creation = true  # Enable automatic IPv6 assignment

#   # Optional: Assign tags to your subnets
#   tags = {
#     Name = "GreenEnco_Public Subnet-02"
#   }
# }

resource "aws_subnet" "private_01" {
  vpc_id            = aws_vpc.vpc.id  # Replace with your VPC ID
  cidr_block        = var.private_subnet_02  # Replace with your desired CIDR block
  availability_zone = var.availability_zone1 # Replace with your desired Availability Zone
  map_public_ip_on_launch = false         # Ensures this is a private subnet

  # Optional: Assign tags to your subnets
  tags = {
    Name = "GreenEnco_Private Subnet-1"
  }
}

resource "aws_subnet" "private_02" {
  vpc_id            = aws_vpc.vpc.id  # Replace with your VPC ID
  cidr_block        = var.private_subnet_03  # Replace with your desired CIDR block
  availability_zone = var.availability_zone2 # Replace with your desired Availability Zone
  map_public_ip_on_launch = false         # Ensures this is a private subnet

  # Optional: Assign tags to your subnets
  tags = {
    Name = "GreenEnco_Private Subnet-2"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "NAT EIP"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_01.id  # Attach NAT to a public subnet
  tags = {
    Name = "GreenEnco_NAT Gateway"
  }

  depends_on = [aws_internet_gateway.igw] # Ensure IGW exists first
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  # Optional: Assign tags to your Internet Gateway
  tags = {
    Name = "GreenEnco_Internet Gateway"
  }
}

resource "aws_egress_only_internet_gateway" "egress" {
  vpc_id = aws_vpc.vpc.id
}


resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  # Optional: Assign tags to your route table
  tags = {
    Name = "Public_GreenEnco_RouteTable"
  }
}

resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"   # Default route for internet access
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Private_GreenEnco_RouteTable"
  }
}


resource "aws_route_table_association" "subnet1_association" {
  subnet_id      = aws_subnet.public_01.id
  route_table_id = aws_route_table.rt1.id
}

# resource "aws_route_table_association" "subnet2_association" {
#   subnet_id      = aws_subnet.public_02.id
#   route_table_id = aws_route_table.rt1.id
# }

resource "aws_route_table_association" "subnet2_association" {
  subnet_id      = aws_subnet.private_01.id  # Private Subnet ID
  route_table_id = aws_route_table.rt2.id
}

resource "aws_route_table_association" "subnet3_association" {
  subnet_id      = aws_subnet.private_02.id  # Private Subnet ID
  route_table_id = aws_route_table.rt2.id
}
