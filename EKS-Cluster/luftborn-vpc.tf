#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "luftborn-Cluster" {
  cidr_block = "10.0.0.0/16"

  tags = map(
    "Name", "luftborn-Cluster",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "luftborn-Cluster" {
  count = 3

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.luftborn-Cluster.id

  tags = map(
    "Name", "luftborn-Cluster",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "luftborn-Cluster" {
  vpc_id = aws_vpc.luftborn-Cluster.id

  tags = {
    Name = "luftborn-Cluster"
  }
}

resource "aws_route_table" "luftborn-Cluster" {
  vpc_id = aws_vpc.luftborn-Cluster.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.luftborn-Cluster.id
  }
}

resource "aws_route_table_association" "luftborn-Cluster" {
  count = 3

  subnet_id      = aws_subnet.luftborn-Cluster.*.id[count.index]
  route_table_id = aws_route_table.luftborn-Cluster.id
}
