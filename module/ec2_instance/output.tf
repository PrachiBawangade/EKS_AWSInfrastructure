# output "security_group_id_Private" {
#   description = "ID of the Private Security Group"
#   value       = aws_security_group.GreenEnco_security_group_Private.id
# }

# output "security_group_id_Public" {
#   description = "ID of the Public Security Group"
#   value       = aws_security_group.GreenEnco_security_group_Public.id
# }
output "private_sg_id" {
  value = aws_security_group.GreenEnco_security_group_Private.id
}

output "public_sg_id" {
  value = aws_security_group.GreenEnco_security_group_Public.id
}
# output "public_ip" {
#   value = aws_instance.Ec2_instance_1[*].public_ip
# }
# output "ec2_public_ip" {
#   value = aws_instance.Ec2_instance_1.public_ip
# }

# output "elastic_ip_Public" {
#   value = aws_eip.elastic_ip_public.public_ip
# }

output "ec2_elastic_ip" {
  value = aws_eip.elastic_ip_public.public_ip
}

# Output Private Instance Private IP
output "private_ec2_private_ip" {
  value = aws_instance.Ec2_instance_1.private_ip
}

output "security_group_id" {
  value = aws_security_group.GreenEnco_security_group_Private.id
}

# output "elastic_ip_Private" {
#   value = module.ec2_instance.elastic_ip_Private
# }
