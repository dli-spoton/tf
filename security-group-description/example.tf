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
      "ingress,tcp,8383-8443" = {
        cidrs = [
          "10.0.15.0/24",
          "10.0.25.0/24",
        ]
        description = "Allow ingress on TCP 8383 to 8443"
      }
      "egress,tcp,80" = {
        cidrs       = ["0.0.0.0/0"]
        description = "Outbound HTTP to any"
      }
      "egress,tcp,443" = {
        ## description is optional
        cidrs = ["0.0.0.0/0"]
      }
      "egress,udp,-1" = {
        cidrs       = ["8.8.8.8/32", "1.1.1.1/32", ]
        description = "outbound UDP any to specific hosts"
      }
    }
    sg_ids = {
      "ingress,tcp,3389" = {
        sg_id       = "some_security_group_id"
        description = "allows RDP from some_security_group_id"
      }
    }
    # use security group id as the key instead
    per_sg_id = {
      a_different_security_group_id = {
        # no description for outbound RDP
        "egress,tcp,3389" = ""
        "egress,tcp,22"   = "outbound ssh"
      }
    }
    self = {
      # creates a paired ingress/egress rule, so no need to specify a direction
      "icmp,-1" = "allow all ICMP to other members of this secruity group"
    }
  }
}
