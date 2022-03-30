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

# Set up routes to the internet from our new peered VPC
resource "aws_route" "this_route_to_internet" {
  provider               = "aws.peer"
  route_table_id         = "${aws_vpc.this.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this_inet_gw.id}"
}

### SETUP VPC PEERING ###

module "this_vpc_peer" {
  source = "./peer_connection"

  providers = {
    "aws.primary" = "aws.primary"
    "aws.peer"    = "aws.peer"
  }

  name = "${var.name}"

  # The way the sub module and this parent one refer to "primary" and
  # "peer" is reversed since the perspective is a little different.
  # The peer_vpc_id is the vpc that we want to peer our created one to
  # so it's the VPC in the "primary" AWS account.
  primary_vpc_id = "${var.peer_vpc_id}"

  peer_vpc_id = "${aws_vpc.this.id}"

  tags                     = "${var.tags}"
  vpc_peer_connection_tags = "${var.vpc_peer_connection_tags}"
}

### VPC PEER ROUTING ###

module "this_peering_routes" {
  source = "./peer_routing"

  providers = {
    "aws.primary" = "aws.primary"
    "aws.peer"    = "aws.peer"
  }

  # The way the sub module and this parent one refer to "primary" and
  # "peer" is reversed since the perspective is a little different.
  primary_route_table_id = "${var.peer_route_table_id}"

  peer_route_table_id = "${aws_vpc.this.main_route_table_id}"

  # CIDR Blocks for the existing VPC we want to peer to
  primary_cidr_blocks = "${var.peer_cidr_blocks}"

  # CIDR Block for the VPC we just created
  peer_cidr_block = "${var.cidr_block}"

  primary_vpc_peering_connection_id = "${module.this_vpc_peer.peering_connection_accepter_id}"
  peer_vpc_peering_connection_id    = "${module.this_vpc_peer.peering_connection_id}"
}
