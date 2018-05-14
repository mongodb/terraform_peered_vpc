output "peering_connection_id" {
  value = "${aws_vpc_peering_connection.this_vpc_peer.id}"
}

output "peering_connection_accepter_id" {
  value = "${aws_vpc_peering_connection_accepter.this_vpc_peer_accepter.id}"
}
