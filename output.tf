# output "ec2_public_ip" {
#   value = module.ec2.public_ip
# }

output "ec2_elastic_ip" {
  value = module.ec2.ec2_elastic_ip
}



output "private_sg_id" {
  value = module.ec2.private_sg_id
}

output "public_sg_id" {
  value = module.ec2.public_sg_id
}

