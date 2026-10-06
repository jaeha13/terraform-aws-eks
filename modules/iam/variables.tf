variable "aws_iam_role_name" {
    description = "Name of iam role"
    type        = string
    default     = "ec2-role"
}

variable "aws_iam_instance_profile_name" {
    description = "Name of iam instance profile"
    type        = string
    default     = "ec2-instance-profile"
}