output "bastion_instance_id" {
  description = "ID of the Bastion EC2 instance."
  value       = aws_instance.bastion.id
}

output "bastion_private_ip" {
  description = "Private IP address of the Bastion EC2 instance."
  value       = aws_instance.bastion.private_ip
}