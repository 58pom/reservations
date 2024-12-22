#----------------------------------------
# VPCの作成
#----------------------------------------
resource "aws_vpc" "reservation-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name= "reservation-vpc"
  }
}
#----------------------------------------
# パブリックサブネットの作成
#----------------------------------------
resource "aws_subnet" "elb-subnet-01" {
  vpc_id                  = aws_vpc.reservation-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "elb-subnet-01"
  }
}

resource "aws_subnet" "elb-subnet-02" {
  vpc_id                  = aws_vpc.reservation-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "elb-subnet-02"
  }
}

resource "aws_subnet" "api-subnet-01" {
  vpc_id                  = aws_vpc.reservation-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "api-subnet-01"
  }
}

resource "aws_subnet" "api-subnet-02" {
  vpc_id                  = aws_vpc.reservation-vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "api-subnet-02"
  }
}
#----------------------------------------
# インターネットゲートウェイの作成
#----------------------------------------
resource "aws_internet_gateway" "reservation-igw" {
  vpc_id = aws_vpc.reservation-vpc.id

    tags = {
    Name = "reservation-igw"
  }
}
#----------------------------------------
# ルートテーブルの作成
#----------------------------------------
resource "aws_route_table" "sample_rtb" {
  vpc_id = aws_vpc.reservation-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.reservation-igw.id
  }
  tags = {
      Name = "reservation-rtb"
  }
}
#----------------------------------------
# サブネットにルートテーブルを紐づけ
#----------------------------------------
resource "aws_route_table_association" "sample_rt_assoc" {
  subnet_id      = aws_subnet.elb-subnet-01.id
  route_table_id = aws_route_table.sample_rtb.id
}
#----------------------------------------
# セキュリティグループの作成
#----------------------------------------
resource "aws_security_group" "sample_sg" {
  name   = "sample-sg"
  vpc_id = aws_vpc.reservation-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}