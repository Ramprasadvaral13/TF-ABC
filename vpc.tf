resource "aws_vpc" "demo-vpc" {
    cidr_block = var.vpc-cidr
  
}

resource "aws_internet_gateway" "demo-igw" {
    vpc_id = aws_vpc.demo-vpc.id
  
}

resource "aws_subnet" "demo-vpc-public" {
    for_each = var.subnets
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = each.value.cidr
    availability_zone = each.value.az
    map_public_ip_on_launch = each.value.public
    
}

resource "aws_route_table" "demo-vpc-public-rt" {
    vpc_id = aws_vpc.demo-vpc.id
    route {
        cidr_block = var.route-cidr
        gateway_id = aws_internet_gateway.demo-igw.id
    }
  
}

resource "aws_route_table_association" "demo-vpc-public-rta" {
    subnet_id = aws_subnet.demo-vpc-public.id
    route_table_id = aws_route_table.demo-vpc-public-rt.id
  
}

resource "aws_eip" "demo-eip" {
    domain = "vpc"
  
}

resource "aws_nat_gateway" "demo-vpc-nat" {
    subnet_id = aws_subnet.demo-vpc-public.id
    allocation_id = aws_eip.demo-eip.id
  
}

resource "aws_route_table" "demo-vpc-private-rt" {
    vpc_id = aws_vpc.demo-vpc.id
    route {
        cidr_block = var.route-cidr
        gateway_id = aws_nat_gateway.demo-vpc-nat.id
    }
  
}

resource "aws_route_table_association" "demo-vpc-private-rta" {
    subnet_id = aws_subnet.demo-vpc-private.id
    route_table_id = aws_route_table.demo-vpc-public-rt.id
  
}