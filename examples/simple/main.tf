provider "aws" {
  alias   = "kernel_build"
  profile = "kernel_build"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "kernel_build2"
  profile = "kernel_build2"
  region  = "us-east-1"
}

module "package_testing_vpc" {
  source = "../../"

  providers = {
    aws.primary = aws.kernel_build
    aws.peer    = aws.kernel_build2
  }

  peer_vpc_id         = "vpc-e2164b9b"
  peer_route_table_id = "rtb-a4cb3fdf"
  peer_cidr_blocks    = ["10.123.0.0/16"]

  name               = "package_testing_vpc"
  availability_zones = ["us-east-1a"]
  cidr_block         = "10.131.0.0/16"

  tags = {
    Env = "stage"
  }
}
