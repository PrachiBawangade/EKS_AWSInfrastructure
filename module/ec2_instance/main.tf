# To create the Ec2 instance in private subnet
resource "aws_instance" "Ec2_instance_1" {
  ami                         = var.ami_value           # Change to your desired AMI ID
  instance_type               = var.instance_type_value # Change to your desired instance type
  subnet_id                   = var.private_subnet_02
  associate_public_ip_address = false      # Ensure no public IP
  key_name                    = aws_key_pair.key_pair.key_name # Change to your key pair name
  availability_zone           = "ap-south-1b" 
  # count                       = var.instance_count
  vpc_security_group_ids = [aws_security_group.GreenEnco_security_group_Private.id]
  # tenancy                     = var.instance_tenancy    # Specify dedicated tenancy
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  tags = {
    Name = "GreenEnco_Prod(workernode)_Instance"
  }
}

# To create the Ec2 instance in public subnet
resource "aws_instance" "Ec2_instance_2" {
  ami                         = var.ami_value
  instance_type               = var.instance_type_value_Public
  subnet_id                   = var.public_subnet_01
  associate_public_ip_address = true  # Public instance gets a public IP
  key_name                    = aws_key_pair.key_pair.key_name
  availability_zone           = "ap-south-1a"
  vpc_security_group_ids = [aws_security_group.GreenEnco_security_group_Public.id]
  ipv6_address_count          = 1  # Assign 1 IPv6 address automatically
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  tags = {
    Name = "GreenEnco_Development_Instance"
  }
}


# RSA key of size 4096 bits
resource "tls_private_key" "rsa-4096-GreenEnco" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa-4096-GreenEnco.public_key_openssh
}

resource "local_file" "private_key" {
  content = tls_private_key.rsa-4096-GreenEnco.private_key_pem
  filename = var.key_name
}

# # Allocate an Elastic IP for Private subnet
# resource "aws_eip" "elastic_ip_Private" {
#   domain      = "vpc"
#   instance    = aws_instance.Ec2_instance_1.id

#   tags = {
#     Name = "GreenEncoElasticIP_Private"
#   }
# }

# Allocate an Elastic IP for Public Instance
resource "aws_eip" "elastic_ip_public" {
  domain    = "vpc"
  instance  = aws_instance.Ec2_instance_2.id

  tags = {
    Name = "GreenEncoElasticIP_Public"
  }
}

# Associate the Elastic IP with an EC2 instance
# resource "aws_eip_association" "eip_assoc_Private" {
#   instance_id   = aws_instance.Ec2_instance_1.id
#   allocation_id = aws_eip.elastic_ip.id
# }

# # Associate the Elastic IP with an EC2 instance
# resource "aws_eip_association" "eip_assoc_Public" {
#   instance_id   = aws_instance.Ec2_instance_2.id
#   allocation_id = aws_eip.elastic_ip.id
# }

# Create a security group
resource "aws_security_group" "GreenEnco_security_group_Private" {
  name = "GreenEnco-Private-SG"
  description = "Greenenco security group_Private"
  vpc_id      = var.vpc_id
  
  # Define your security group rules as needed
  # For example, allow SSH and HTTP traffic
  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPs access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # # Allow HTTP access (port 8080) for Jenkins web interface
  # ingress {
  #   description = "jenkins access"
  #   from_port   = 8080
  #   to_port     = 8080
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # Allow HTTP access (port 8080) for Jenkins web interface
  # ingress {
  #   description = "sonarqube access"
  #   from_port   = 9000
  #   to_port     = 9000
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create a security group Public
resource "aws_security_group" "GreenEnco_security_group_Public" {
  name = "GreenEnco-Public-SG"
  description = "Greenenco security group_Public"
  vpc_id      = var.vpc_id

  # Define your security group rules as needed
  # For example, allow SSH and HTTP traffic
  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPs access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "sonarqube access"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
  