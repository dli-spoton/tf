provider "aws" {
  region = "us-west-2"
}
# pulls all VPCs
data "aws_vpcs" "all" {}

output "vpc_all" {
  value = data.aws_vpcs.all
}

# returns something like:
# + vpc_all = {
#     + filter = null
#     + id     = "us-west-2"
#     + ids    = [
#         + "vpc-06fa49c7dfc045e4f",
#         + "vpc-6456521d",
#       ]
#     + tags   = null
#   }

# data.aws_vpcs.all.ids would be:
# + ids    = [
#     + "vpc-06fa49c7dfc045e4f",
#     + "vpc-6456521d",
#   ]
# use it to get details for all vpcs
data "aws_vpc" "each" {
  ## need to explicitly convert list to set when using them for for_each
  for_each = toset(data.aws_vpcs.all.ids)
  ## each.key would be each item in the list
  id = each.key
}

output "vpc_each" {
  value = data.aws_vpc.each
}

#  + vpc_each = {
#       + vpc-06fa49c7dfc045e4f = {
#           + cidr_block              = "192.168.0.0/16"
#           + default                 = false
#           + id                      = "vpc-06fa49c7dfc045e4f"
#           + main_route_table_id     = "rtb-07ec72093a4f985f0"
#           + tags                    = {}
#         }
#       + vpc-6456521d          = {
#           + cidr_block              = "172.31.0.0/16"
#           + default                 = true
#           + id                      = "vpc-6456521d"
#           + main_route_table_id     = "rtb-98c2cce0"
#           + tags                    = {}
#         }
#     }

output "vpc_each_map" {
  # you need to enclose for expressions in [] or {}
  # to denote that the result is a list or map
  value = {
    # use a for loop to pull route table
    for vpc_id, vpc_details in data.aws_vpc.each :
    # need to specify a [key] => [value] for a map
    vpc_id => vpc_details.main_route_table_id
  }
}
# + vpc_each_map = {
#     + vpc-06fa49c7dfc045e4f = "rtb-07ec72093a4f985f0"
#     + vpc-6456521d          = "rtb-98c2cce0"
#   }

output "vpc_each_list" {
  value = [
    # only need a value for lists
    for vpc_id, vpc_details in data.aws_vpc.each : vpc_details.main_route_table_id
  ]
}
# + vpc_each_list = [
#     + "rtb-07ec72093a4f985f0",
#     + "rtb-98c2cce0",
#   ]
