### VPC Vars

variable "name" {
  description = "The name of this VPC. The names of other resources will include this as part of the name. Required."
}

variable "tags" {
  description = "A mapping of tags to assign to each resource. Default: {}"
  default     = {}
}

variable "vpc_peer_connection_tags" {
  description = "A mapping of tags to apply only to the VPC peering connections. Merged with var.tags. Default: {}"
  default     = {}
}

variable "primary_vpc_id" {
  description = "The primary account VPC ID"
}

variable "peer_vpc_id" {
  description = "The peer account VPC ID"
}
