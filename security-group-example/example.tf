provider "aws" {
  region = "us-west-2"
}
# pulls the default VPC
data "aws_vpcs" "default" {
  filter {
    name   = "is-default"
    values = [true]
  }
}
# makes a security group
resource "aws_security_group" "example" {
  name   = "example-security-group"
  vpc_id = data.aws_vpcs.default.ids[0]
}
# uses the module to create rules for the example security group
module "ec2_sg_rules" {
  source            = "./security-group-rules"
  security_group_id = aws_security_group.example.id
  sg_rules          = local.sg_rules
}

locals {
  # security group rules
  sg_rules = {
    ip4_cidr_blocks = {
      ## allows ingress for TCP 8383 to 8443
      "ingress,tcp,8383-8443" = [
        "10.0.15.0/24",
        "10.0.25.0/24",
      ]
      ## egress for HTTP(S)
      "egress,tcp,80"  = ["0.0.0.0/0"]
      "egress,tcp,443" = ["0.0.0.0/0"]
      ## egress for any UDP
      "egress,udp,-1" = [
        "8.8.8.8/32",
        "1.1.1.1/32",
      ]
    }
    sg_ids = {
      ## allows RDP from some_security_group_id
      "ingress,tcp,3389" = "some_security_group_id"
    }
    self = {
      # allow all ICMP to other members of this secruity group
      "icmp,-1" = ""
    }
  }
}
