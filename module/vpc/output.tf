output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_01.id
}

# output "public_subnet1_id" {
#   value = aws_subnet.public_02.id
# }

# output "private_subnet_id"{
#   value = aws_subnet.private.id
# }

output "private_subnet_id_1" {
  value = aws_subnet.private_01.id
}

output "private_subnet_id_2" {
  value = aws_subnet.private_02.id
}
