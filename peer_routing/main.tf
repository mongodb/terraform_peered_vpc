provider "aws" {
  alias = "primary"
}

provider "aws" {
  alias = "peer"
}

### VPC PEER ROUTING ###

# Set up routes to the primary VPC from our new peered VPC
resource "aws_route" "route_to_primary_from_peer" {
  provider = aws.peer
  count    = length(var.primary_cidr_blocks)

  route_table_id            = var.peer_route_table_id
  destination_cidr_block    = var.primary_cidr_blocks[count.index]
  vpc_peering_connection_id = var.peer_vpc_peering_connection_id
}

# Set up routes to the peer VPC from the primary VPC
resource "aws_route" "route_to_peer_from_primary" {
  provider                  = aws.primary
  route_table_id            = var.primary_route_table_id
  destination_cidr_block    = var.peer_cidr_block
  vpc_peering_connection_id = var.primary_vpc_peering_connection_id
}

