variable "primary_route_table_id" {
  description = "Route table id for the primary VPC"
}

variable "primary_cidr_block" {
  description = "CIDR Block for the primary VPC"
}

variable "peer_route_table_id" {
  description = "Route table id for the peer VPC"
}

variable "peer_cidr_block" {
  description = "CIDR Block for the peer VPC"
}

variable "primary_vpc_peering_connection_id" {
  description = "The peering connection for the primary account (accepter)"
}

variable "peer_vpc_peering_connection_id" {
  description = "The peering connection for the peer account"
}
