
## ipv4 cidr blocks
resource "aws_security_group_rule" "ip4_cidr_blocks" {
  for_each = try(var.sg_rules.ip4_cidr_blocks, {})
  type     = split(",", each.key)[0]
  protocol = split(",", each.key)[1]
  ## example key: ingress,tcp,49152-65535
  ## split(",", each.key)[2] - extracts port range from key
  ## conditinal to use "-1" if the port range = "-1"
  ## split("-", split(",", each.key)[2])[0] - extracts from_port out of key
  from_port = split(",", each.key)[2] == "-1" ? "-1" : split("-", split(",", each.key)[2])[0]
  ## example key: ingress,udp,445
  ## use of element() here to return the from_port if there is no to_port
  to_port           = split(",", each.key)[2] == "-1" ? "-1" : element(split("-", split(",", each.key)[2]), 1)
  cidr_blocks       = each.value
  security_group_id = var.security_group_id
}

## source security group ids
resource "aws_security_group_rule" "sg_ids" {
  for_each = try(var.sg_rules.sg_ids, {})
  type     = split(",", each.key)[0]
  protocol = split(",", each.key)[1]
  ## example key: ingress,tcp,49152-65535
  ## split(",", each.key)[2] - extracts port range from key
  ## conditinal to use "-1" if the port range = "-1"
  ## split("-", split(",", each.key)[2])[0] - extracts from_port out of key
  from_port = split(",", each.key)[2] == "-1" ? "-1" : split("-", split(",", each.key)[2])[0]
  ## example key: ingress,udp,445
  ## use of element() here to return the from_port if there is no to_port
  to_port                  = split(",", each.key)[2] == "-1" ? "-1" : element(split("-", split(",", each.key)[2]), 1)
  source_security_group_id = each.value
  security_group_id        = var.security_group_id
}

locals {
  ## takes the map in per_sg_id and converts it to a list of per_sg_id,rule
  per_sg_id = flatten([
    for sg_id, rule_list in try(var.sg_rules.per_sg_id, {}) : [
      for sg_rule in rule_list : "${sg_id},${sg_rule}"
    ]
  ])
}
resource "aws_security_group_rule" "per_sg_id" {
  for_each                 = toset(local.per_sg_id)
  type                     = split(",", each.key)[1]
  protocol                 = split(",", each.key)[2]
  from_port                = split(",", each.key)[3] == "-1" ? "-1" : split("-", split(",", each.key)[3])[0]
  to_port                  = split(",", each.key)[3] == "-1" ? "-1" : element(split("-", split(",", each.key)[3]), 1)
  source_security_group_id = split(",", each.key)[0]
  security_group_id        = var.security_group_id
}

## self
resource "aws_security_group_rule" "self_egress" {
  for_each          = try(var.sg_rules.self, {})
  type              = "egress"
  protocol          = split(",", each.key)[0]
  from_port         = split(",", each.key)[1] == "-1" ? "-1" : split("-", split(",", each.key)[1])[0]
  to_port           = split(",", each.key)[1] == "-1" ? "-1" : element(split("-", split(",", each.key)[1]), 1)
  self              = true
  security_group_id = var.security_group_id
}
resource "aws_security_group_rule" "self_ingress" {
  for_each          = try(var.sg_rules.self, {})
  type              = "ingress"
  protocol          = split(",", each.key)[0]
  from_port         = split(",", each.key)[1] == "-1" ? "-1" : split("-", split(",", each.key)[1])[0]
  to_port           = split(",", each.key)[1] == "-1" ? "-1" : element(split("-", split(",", each.key)[1]), 1)
  self              = true
  security_group_id = var.security_group_id
}
