# VPC
resource "aws_vpc" "Projectvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  

  tags = {
    Name = "Projectvpc"
  }
}

# subnets
resource "aws_subnet" "Public-1" {
  vpc_id     = aws_vpc.Projectvpc.id
  cidr_block = "10.0.0.0/25"
  
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Public-1"
  }
}
resource "aws_subnet" "Public-2" {
  vpc_id     = aws_vpc.Projectvpc.id
  cidr_block = "10.0.0.128/26"
  
  availability_zone = "ap-south-1b"
  tags = {
    Name = "Public-2"
  }
}

resource "aws_subnet" "Private-1" {
  vpc_id     = aws_vpc.Projectvpc.id
  cidr_block = "10.0.1.0/25"
  
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Private-1"
  }
}
resource "aws_subnet" "Private-2" {
  vpc_id     = aws_vpc.Projectvpc.id
  cidr_block = "10.0.1.128/25"
  
  availability_zone = "ap-south-1b"
  tags = {
    Name = "Private-2"
  }
}

# internet gateway
resource "aws_internet_gateway" "Project_igw" {
  vpc_id = aws_vpc.Projectvpc.id

  tags = {
    Name = "Project_igw"
  }
}

# NAT gateway
resource "aws_nat_gateway" "Project_nat_gw" {
  allocation_id = aws_eip.project_eip.id
  subnet_id     = aws_subnet.Public-1.id

  tags = {
    Name  = "Project_nat_gw"

  }
  depends_on = [aws_internet_gateway.Project_igw]
}

# elastic ip for nat gateway
resource "aws_eip" "project_eip" {
  domain = "vpc"
  tags = {
    Name  = "project_eip"
  }
}
# Route table for public subnets
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.Projectvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Project_igw.id
  }

  tags = {
    Name  = "rt_public"
  }
}
resource "aws_route_table_association" "rta_public_1" {
  subnet_id      = aws_subnet.Public-1.id
  route_table_id = aws_route_table.rt_public.id
}
resource "aws_route_table_association" "rta_public_2" {
  subnet_id      = aws_subnet.Public-2.id
  route_table_id = aws_route_table.rt_public.id
}


# Route table for private subnets
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.Projectvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Project_nat_gw.id
  }

  tags = {
    Name  = "rt_private"
  }
}

resource "aws_route_table_association" "rta_private_1" {
  subnet_id      = aws_subnet.Private-1.id
  route_table_id = aws_route_table.rt_private.id
}
resource "aws_route_table_association" "rta_private_2" {
  subnet_id      = aws_subnet.Private-2.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_security_group" "Private_sg" {
  name        = "Private_sg"
  description = "Private security group"
  vpc_id      = aws_vpc.Projectvpc.id

  tags = {
    Name = "Private_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.Private_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports

}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.Private_sg.id
  #cidr_ipv4         = "0.0.0.0/0"
  from_port         = 30005
  ip_protocol       = "tcp"
  to_port           = 30005
  referenced_security_group_id = aws_security_group.ALB_sg.id
}

resource "aws_security_group" "ALB_sg" {
  name        = "ALB_sg"
  description = "ALB security group"
  vpc_id      = aws_vpc.Projectvpc.id

  tags = {
    Name = "ALB_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.ALB_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls" {
  security_group_id = aws_security_group.ALB_sg.id
  cidr_ipv4         = "0.0.0.0/0" 
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_security_group" "jenkins_sg" {
  name        = "Jenkins_sg"
  description = "Jenkins security group"
  vpc_id      = aws_vpc.Projectvpc.id

  tags = {
    Name = "Jenkins_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports

}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
  
}
