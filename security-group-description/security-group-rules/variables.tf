
variable "security_group_id" {
  description = "AWS Security Group ID."
  type        = string
}

variable "sg_rules" {
  description = "Object containing security group rules."
  type        = any
  default     = {}
}
