module "vpc" {
  source = "./module/vpc"

  # Pass variables to VPC module
  vpc_id                  = "10.0.0.0/16"
  instance_tenancy        = "default"
  enable_dns_support      = "true" # If set to true, DNS queries can be resolved within the VPC (e.g., for instances to communicate using private DNS names).
  enable_dns_hostnames    = "true" # If set to true, instances with public IPs will also receive public DNS hostnames
  public_subnet_01        = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "true" # Enable auto-assign public IP
  # public_subnet_02        = "10.0.2.0/24"
  # availability_zone1      = "ap-south-1b"
  private_subnet_02  = "10.0.2.0/24"
  availability_zone1 = "ap-south-1b"
  private_subnet_03  = "10.0.3.0/24"
  availability_zone2 = "ap-south-1a"

}


module "ec2" {
  source = "./module/ec2_instance"

  # Pass variables to EC2 module
  ami_value                   = "ami-00bb6a80f01f03502"
  instance_type_value         = "t3a.medium"
  instance_type_value_Public  = "t3a.xlarge"
  key_name                    = "GreenEnco_mumbai.pem"
  instance_count              = 1
  public_subnet_01            = module.vpc.public_subnet_id
  private_subnet_02           = module.vpc.private_subnet_id_1 # Ensure this is the correct variable
  private_subnet_03           = module.vpc.private_subnet_id_2
  availability_zone1          = "ap-south-1b"
  availability_zone           = "ap-south-1a"
  availability_zone2          = "ap-south-1a"
  associate_public_ip_address = false # Enable a public IP
  vpc_id                      = module.vpc.vpc_id
  # security_group_id_Private = module.ec2.private_sg_id
  # security_group_id_Public  = module.ec2.public_sg_id
  # instance_tenancy       = "dedicated"
  volume_size = 30
  volume_type = "gp3"
}

module "ecr" {
  source = "./module/ecr"

  repository_name   = "greenenco-docker-img-repo"
  vpc_id            = module.vpc.vpc_id
  public_subnet_01  = module.vpc.public_subnet_id
  private_subnet_02 = module.vpc.private_subnet_id_1
  private_subnet_03 = module.vpc.private_subnet_id_2
  security_group_id = module.ec2.security_group_id
}

module "eks" {
  source = "./module/eks"

  # Pass variables to EKS module
  security_group_name     = "EKS_Cluster_Security_Group"
  ec2_security_group_pass = module.ec2.security_group_id
  # vpc_cidr_block            = module.vpc.vpc_cidr_block
  role_name                 = "EKS_Cluster_Role_1"
  private_subnet_id_value_1 = module.vpc.private_subnet_id_value_1
  private_subnet_id_value_2 = module.vpc.private_subnet_id_value_2
  worker_node_role          = "EKS_Workernode_Role_1"
  ebs_policy                = "EBS_Policy_1"
  instance_type_value       = "t3.medium"
  cluster_name              = "eks-1"
  workernode_name           = "Node_01"
  key_name                  = "varma.pem"
  vpc_id                    = module.vpc.vpc_id
}

# resource "null_resource" "name" {
#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = file(var.private_key_path)
#     host        = module.ec2.public_ip[0]
#   }

#   provisioner "file" {
#     source      = "./module/ec2_instance/jenkins.sh"
#     destination = "/home/ubuntu/jenkins.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       # Check if .env exists before deleting
#       "[ -f /home/ubuntu/.env ] && rm /home/ubuntu/.env || echo '.env not found, skipping removal'",

#       # Set up AWS credentials
#       "mkdir -p /home/ubuntu/.aws",
#       "echo '[default]' > /home/ubuntu/.aws/config",
#       "echo 'region = ${var.region}' >> /home/ubuntu/.aws/config",
#       "echo '[default]' > /home/ubuntu/.aws/credentials",
#       "echo 'aws_access_key_id = ${var.access_key}' >> /home/ubuntu/.aws/credentials",
#       "echo 'aws_secret_access_key = ${var.secret_key}' >> /home/ubuntu/.aws/credentials",

#       # Ensure script is in correct format
#       "sudo apt install dos2unix -y",
#       "dos2unix /home/ubuntu/jenkins.sh",s
#       "sudo chmod +x /home/ubuntu/jenkins.sh",

#       # Run the script correctly
#       "sudo /home/ubuntu/jenkins.sh"
#     ]
#   }

#   depends_on = [module.ec2]
# }


resource "null_resource" "name" {

  # Upload the Jenkins script to the private EC2 instance
  provisioner "file" {
    source      = "module/ec2_instance/jenkins.sh" # Ensure this file exists locally
    destination = "/home/ubuntu/jenkins.sh"        # Path where the script will be stored on EC2
  }

  # SSH Connection Settings (through Bastion Host)
  connection {
    type         = "ssh"
    user         = "ubuntu"
    private_key  = file(var.private_key_path)        # Path to your private SSH key
    host         = module.ec2.private_ec2_private_ip # Private EC2 instance IP
    bastion_host = module.ec2.ec2_elastic_ip         # Public Bastion Host IP
  }

  # Execute the Jenkins script remotely on the private EC2 instance
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/jenkins.sh",
      "sudo chown ubuntu:ubuntu /home/ubuntu/jenkins.sh",
      "ls -lah /home/ubuntu/",                # Debugging: Check file permissions
      "file /home/ubuntu/jenkins.sh",         # Debugging: Check file type
      "sudo bash -x /home/ubuntu/jenkins.sh", # Execute script with debugging
      "sudo /home/ubuntu/jenkins.sh"
    ]
  }
}
