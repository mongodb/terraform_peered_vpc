### VPC Vars

variable "name" {
  description = "The name of this VPC. The names of other resources will include this as part of the name. Required."
}

variable "availability_zones" {
  description = "A list of availability zones to create this vpc in. Required."

  # This variable is required but if we don't put a blank list in here
  # Terraform is very unhappy when we try to "iterate" it with count etc.
  default = []
}

variable "cidr_block" {
  description = "CIDR block for this vpc. Required."
}

variable "instance_tenancy" {
  description = "Instance tenancy. Default: default"
  default     = "default"
}

variable "enable_dns_hostnames" {
  description = "Whether to enable dns_hostnames or not. Default: true"
  default     = true
}

variable "tags" {
  description = "A mapping of tags to assign to each resource. Default: {}"
  default     = {}
}

variable "vpc_tags" {
  description = "A mapping of tags to apply only to the VPC. Merged with var.tags. Default: {}"
  default     = {}
}

variable "inet_gw_tags" {
  description = "A mapping of tags to apply only to the Internet Gateway. Merged with var.tags. Default: {}"
  default     = {}
}

variable "public_subnet_tags" {
  description = "A mapping of tags to apply only to the Public Subnet. Merged with var.tags. Default: {}"
  default     = {}
}

variable "vpc_peer_connection_tags" {
  description = "A mapping of tags to apply only to the VPC peering connections. Merged with var.tags. Default: {}"
  default     = {}
}

### Subnet Vars

variable "public_subnet_nat_availability_zone" {
  description = "Which availability zone to use for the NAT subnet. Default: us-east-1a"
  default     = "us-east-1a"
}

variable "public_subnet_nat_map_public_ip" {
  description = "Whether or not to map the public ip on launch for the NAT subnet. Default: true"
  default     = true
}

variable "peer_vpc_id" {
  description = "What VPC to peer this VPC with."
}

variable "peer_cidr_blocks" {
  default     = []
  description = "What CIDR blocks the peer VPC uses."
}

variable "peer_route_table_id" {
  description = "What route to add the Peering route table to."
}
