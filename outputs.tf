output "public_subnets" {
  value = ["${aws_subnet.this_public_subnet.*.id}"]
}

output "vpc_id" {
  value = "${aws_vpc.this.id}"
}

output "inet_gw_id" {
  value = "${aws_internet_gateway.this_inet_gw.id}"
}

output "name" {
  value = "${var.name}"
}

output "peer_cidr_block" {
  value = "${var.peer_cidr_block}"
}

output "peer_vpc_id" {
  value = "${var.peer_vpc_id}"
}

output "peer_route_table_id" {
  value = "${var.peer_route_table_id}"
}

output "cidr_block" {
  value = "${var.cidr_block}"
}
