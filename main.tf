provider "aws" {
  alias = "primary"
}

provider "aws" {
  alias = "peer"
}

### SETUP THE VPC ###

# Create the VPC in the peer account
resource "aws_vpc" "this" {
  provider             = "aws.peer"
  cidr_block           = "${var.cidr_block}"
  instance_tenancy     = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"

  tags = "${merge(var.vpc_tags, var.tags, map("Name", var.name))}"
}

# Internet Gateway create and attach
resource "aws_internet_gateway" "this_inet_gw" {
  provider = "aws.peer"
  vpc_id   = "${aws_vpc.this.id}"

  tags = "${merge(var.inet_gw_tags, var.tags, map("Name", format("%s.InternetGateway", var.name)))}"
}

# Create subnets in all availability zone listed in availability_zones variable
resource "aws_subnet" "this_public_subnet" {
  provider                = "aws.peer"
  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${cidrsubnet(var.cidr_block, 4, count.index)}"
  map_public_ip_on_launch = "${var.public_subnet_nat_map_public_ip}"
  availability_zone       = "${var.availability_zones[count.index]}"
  count                   = "${length(var.availability_zones)}"

  tags = "${merge(var.public_subnet_tags, var.tags, map("Name", format("%s.subnet_%s", var.name, var.availability_zones[count.index])))}"
}

### SETUP VPC PEERING ###

data "aws_caller_identity" "peer" {
  provider = "aws.peer"
}

# Create the peering connection in the primary account
resource "aws_vpc_peering_connection" "this_vpc_peer" {
  provider      = "aws.primary"
  vpc_id        = "${var.peer_vpc_id}"
  peer_vpc_id   = "${aws_vpc.this.id}"
  peer_owner_id = "${data.aws_caller_identity.peer.account_id}"
  auto_accept   = false

  tags = "${merge(var.vpc_peer_connection_tags, var.tags, map("Side", "Requester"), map("Name", format("%s.peer_to_%s", var.name, var.peer_vpc_id)))}"
}

# Accept the peering connection request in peer account
resource "aws_vpc_peering_connection_accepter" "this_vpc_peer_accepter" {
  provider                  = "aws.peer"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.this_vpc_peer.id}"
  auto_accept               = true

  tags = "${merge(var.vpc_peer_connection_tags, var.tags, map("Side", "Accepter"), map("Name", format("%s.peer_to_%s", var.peer_vpc_id, var.name)))}"
}

### VPC PEER ROUTING ###

# Set up routes to the primary VPC from our new peered VPC
resource "aws_route" "this_route_to_peer" {
  provider                  = "aws.peer"
  route_table_id            = "${aws_vpc.this.main_route_table_id}"
  destination_cidr_block    = "${var.peer_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection_accepter.this_vpc_peer_accepter.id}"
}

# Set up routes to the internet from our new peered VPC
resource "aws_route" "this_route_to_internet" {
  provider                  = "aws.peer"
  route_table_id            = "${aws_vpc.this.main_route_table_id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = "${aws_internet_gateway.this_inet_gw.id}"
}

# Set up routes to the peer VPC from the primary VPC
resource "aws_route" "this_route_from_peer" {
  provider                  = "aws.primary"
  route_table_id            = "${var.peer_route_table}"
  destination_cidr_block    = "${var.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.this_vpc_peer.id}"
}
