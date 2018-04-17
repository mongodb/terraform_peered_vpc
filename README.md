# terraform\_peered\_vpc

A module for creating peered vpc's in AWS across AWS accounts.

## Usage

To use this module you'll want to add it as a git submodule in your
terraform code.

```bash
$ # Make sure you have a modules directory
$ mkdir -p modules
$ git submodule add https://github.com/mongodb/terraform_peered_vpc modules/peered_vpc
```

Now in your terraform code make sure you set up two providers with Aliases:

```terraform
provider "aws" {
  alias   = "my_primary_account"
  profile = "my_primary_account"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "my_secondary_account"
  profile = "my_secondary_account"
  region  = "us-east-1"
}
```

> **Note:** You probably want to setup a third provider with the
> primary account that has no alias. If you don't do this Terraform
> will not consider you as having a "default" account and some code
> can have unexpected effects.

In this example we are going to create a new VPC in the secondary
account and peer it to a VPC in the primary account. First we need to
create a VPC in the primary account. You can do so with the following:

```terraform
resource "aws_vpc" "primary_vpc" {
    cidr_block = "10.123.0.0/16"
    instance_tenancy = "default"
    enable_dns_hostnames = true
    tags {
        Name = "My Primary VPC"
    }
}
```

Next we're going to create the peered VPC and peering connection using
this module. This example is the simplest possible version. If you
want to read all possible options you can see our section below on Parameters:

```terraform
module "package_testing_vpc" {
  # This must point to the path of where you downloaded the module
  # See the terraform documentation: https://www.terraform.io/docs/modules/usage.html
  # for more inofrmation.
  source = "./modules/peered_vpc"

  providers = {
    "aws.primary" = "aws.my_primary_account"
    # This is the account where the new VPC will be created
    "aws.peer"    = "aws.my_secondary_account"
  }

  # This provides us the information we need on our existing vpc
  # so we can peer it to the new vpc
  peer_vpc_id      = "${module.primary_vpc.id}"
  peer_route_table = "${module.primary_vpc.main_route_table_id}"
  peer_cidr_block  = "${module.primary_vpc.cidr_block}"

  name               = "my_secondary_acount_peered_vpc"
  availability_zones = ["us-east-1a"]
  cidr_block         = "10.131.0.0/16"
}
```

This will create the following resources:

- **Secondary account:** VPC
- **Secondary account:** Internet Gateway in the VPC
- **Secondary account:** Public subnets in all availability zones for
- **Secondary account:** VPC Peering Connection
- **Primary account:** VPC Peering Connection
- **Primary account:** Routes to VPC peering connection for traffic to the Secondary VPC
- **Secondary account:** Routes to VPC peering connection for traffic to the Primary VPC
- **Secondary account:** Routes to the internet gateway

For more information on parameters and outputs see below.

## Parameters

#### name
The name of this VPC. The names of other resources will include this as part of the name. **Required.**

#### availability_zones
A list of availability zones to create this VPC in. **Required.**
This variable is required but if we don't put a blank list in here
Terraform is very unhappy when we try to "iterate" it with count etc.

**Default:** []

#### cidr_block
CIDR block for this vpc. **Required.**

#### instance_tenancy
Instance tenancy.

**Default:** "default"


#### enable_dns_hostnames
Whether to enable dns_hostnames or not.

**Default:** true


#### tags
A mapping of tags to assign to each resource.

**Default:** {}


#### vpc_tags
A mapping of tags to apply only to the VPC. Merged with var.tags.

**Default:** {}


#### inet_gw_tags
A mapping of tags to apply only to the Internet Gateway. Merged with var.tags.

**Default:** {}


#### public_subnet_tags
A mapping of tags to apply only to the Public Subnet. Merged with var.tags.

**Default:** {}


#### vpc_peer_connection_tags
A mapping of tags to apply only to the VPC peering connections. Merged with var.tags.

**Default:** {}


### Subnet Parameters

#### public_subnet_nat_availability_zone
Which availability zone to use for the NAT subnet.

**Default:** "us-east-1a"


#### public_subnet_nat_map_public_ip
Whether or not to map the public ip on launch for the NAT subnet.

**Default:** true


#### peer_vpc_id
What VPC to peer this VPC with.

#### peer_cidr_block
What CIDR block the peer VPC uses.


#### peer_route_table
What route to add the Peering route table to.

## Outputs

#### public_subnets
A list of the public subnet ids that are created.

#### vpc_id
The VPC ID of the created VPC in the "peer" account.

#### vpc_owner_id
The AWS account ID of the "peer" account.

#### inet_gw_id
The AWS ID of the internet gateway.

#### name
The name of the created VPC

#### cidr_block
The CIDR block of the created VPC

#### peer_cidr_block
The CIDR block of the primary VPC which the created VPC is peered to.

#### peer_vpc_id
The VPC ID of the primary VPC which the created VPC is peered to.

#### peer_route_table
The Route Table ID of the primary VPC which the created VPC is peered to.
