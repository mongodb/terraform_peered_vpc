provider "aws" {
  alias = "primary"
}

provider "aws" {
  alias = "peer"
}

### Setup VPC Peering Connection

data "aws_caller_identity" "peer" {
  provider = aws.peer
}

# Create the peering connection in the primary account
resource "aws_vpc_peering_connection" "this_vpc_peer" {
  provider      = aws.primary
  vpc_id        = var.primary_vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_owner_id = data.aws_caller_identity.peer.account_id
  auto_accept   = false

  tags = merge(
    var.vpc_peer_connection_tags,
    var.tags,
    {
      "Side" = "Requester"
    },
    {
      "Name" = format("%s.peer_to_%s", var.name, var.peer_vpc_id)
    },
  )
}

# Accept the peering connection request in peer account
resource "aws_vpc_peering_connection_accepter" "this_vpc_peer_accepter" {
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.this_vpc_peer.id
  auto_accept               = true

  tags = merge(
    var.vpc_peer_connection_tags,
    var.tags,
    {
      "Side" = "Accepter"
    },
    {
      "Name" = format("%s.peer_to_%s", var.peer_vpc_id, var.name)
    },
  )
}

