
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  type        = string
  description = "Name of the SSM patching policy"
  default     = "example"
}

variable "tags" {
  type        = map(string)
  description = "Tags to use for the AWS resources"
  default     = {}
}
