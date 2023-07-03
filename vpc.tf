# VPC 생성
resource "aws_vpc" "my_VPC" {
  cidr_block = "10.0.0.0/16"
}

# subnet 생성(availability_zone1)

resource "aws_subnet" "my_public_sn1" {
    vpc_id = aws_vpc.my_VPC.id
    cidr_block = "10.0.1.0/24"

    availability_zone = var.availability_zone1
    map_public_ip_on_launch = true

    tags = {
        Name = "my_public_subnet1"
    }
}

resource "aws_subnet" "my_private_sn1" {
    vpc_id = aws_vpc.my_VPC.id
    cidr_block = "10.0.2.0/24"

    availability_zone = var.availability_zone1

    tags = {
        Name = "my_private_subnet1"
    }
}

# subnet 생성(availability_zone2)
resource "aws_subnet" "my_public_sn2" {
    vpc_id = aws_vpc.my_VPC.id
    cidr_block = "10.0.101.0/24"

    availability_zone = var.availability_zone2
    map_public_ip_on_launch = true

    tags = {
        Name = "my_public_subnet2"
    }
}

resource "aws_subnet" "my_private_sn2" {
    vpc_id = aws_vpc.my_VPC.id
    cidr_block = "10.0.102.0/24"

    availability_zone = var.availability_zone2

    tags = {
        Name = "my_private_subnet2"
    }
}

# IGW 생성
resource "aws_internet_gateway" "my_IGW" {
  vpc_id = aws_vpc.my_VPC.id

  tags = {
    Name = "my_IGW"
  }
}

# ELP 주소 할당
resource "aws_eip" "NAT_ELP" {
    vpc = true

    lifecycle {
        create_before_destroy = true
    }
}

# NAT-GW 생성
resource "aws_nat_gateway" "my_NATGW" {
    allocation_id = aws_eip.NAT_ELP.id
    subnet_id = aws_subnet.my_public_sn1.id

    tags = {
        Name = "my_NATGW"
    }

    depends_on = [aws_internet_gateway.my_IGW]
}

# 라우팅 테이블 생성
resource "aws_route_table" "my_public_rt" {
    vpc_id = aws_vpc.my_VPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id =  aws_internet_gateway.my_IGW.id
    }

    tags = {
        Name = "my_public-rt"
    }    
}

resource "aws_route_table" "my_private_rt" {
    vpc_id = aws_vpc.my_VPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id =  aws_nat_gateway.my_NATGW.id
    }

    tags = {
        Name = "my_private-rt"
    }    
}


# public 라우팅테이블 연결
resource "aws_route_table_association" "public_rt1_assoc" {
    subnet_id = aws_subnet.my_public_sn1.id
    route_table_id = aws_route_table.my_public_rt.id
}

resource "aws_route_table_association" "public_rt2_assoc" {
    subnet_id = aws_subnet.my_public_sn2.id
    route_table_id = aws_route_table.my_public_rt.id
}

# private 라우팅테이블 연결
resource "aws_route_table_association" "private_rt1_assoc" {
    subnet_id = aws_subnet.my_private_sn1.id
    route_table_id = aws_route_table.my_private_rt.id
}

resource "aws_route_table_association" "private_rt2_assoc" {
    subnet_id = aws_subnet.my_private_sn2.id
    route_table_id = aws_route_table.my_private_rt.id
}

