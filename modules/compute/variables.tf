variable "ami_id" {
    description = "Custom AMI ID. If null, the latest Amazon Linux 2023 AMI is used."
    type        = string
    default     = null
}

variable "instance_type" {
    description = "Instance Type"
    type        = string
    default     = "t3.micro"
}

variable "instance_name" {
    description = "Instance Name"
    type        = string
    default     = null
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile name"
  type        = string
  default     = null
}