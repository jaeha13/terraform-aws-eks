data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "bastion" {
  ami = var.ami_id != null ? var.ami_id : data.aws_ssm_parameter.amazon_linux.value

  instance_type = var.instance_type
  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name = var.instance_name
  }
}