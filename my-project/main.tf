terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
}

# Create the blue instance in the private app subnet az1
# resource "aws_instance" "blue_instance" {
#   ami           = var.ami_id
#   instance_type = var.instance_type
#   subnet_id     = module.vpc.public_subnet_az2_id
#   associate_public_ip_address = true
#   vpc_security_group_ids = [module.security_group.ec2_security_group_id]
#   key_name = var.key-pair

#   user_data = <<-EOF
#               #!/bin/bash
#               sudo yum update -y
#               sudo yum install -y httpd
#               sudo systemctl start httpd
#               sudo systemctl enable httpd

#               # Tạo file index.html với CSS
#               cat <<EOT >> /var/www/html/index.html
#               <!DOCTYPE html>
#               <html lang="en">
#               <head>
#                   <meta charset="UTF-8">
#                   <meta name="viewport" content="width=device-width, initial-scale=1.0">
#                   <title>Green Deployment v1.0</title>
#                   <style>
#                       body {
#                           font-family: Arial, sans-serif;
#                           background-color: #f0f8ff;
#                           margin: 0;
#                           padding: 0;
#                           display: flex;
#                           justify-content: center;
#                           align-items: center;
#                           height: 100vh;
#                       }
#                       .container {
#                           text-align: center;
#                           background-color: #2869e1;
#                           padding: 20px;
#                           border-radius: 10px;
#                           box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
#                           color: white;
#                       }
#                       h1 {
#                           font-size: 2.5em;
#                       }
#                       p {
#                           font-size: 1.2em;
#                       }
#                   </style>
#               </head>
#               <body>
#                   <div class="container">
#                       <h1>Welcome to Blue Deployment v1.1</h1>
#                       <p>This is a static page served from an EC2 instance with enhanced styling!</p>
#                   </div>
#               </body>
#               </html>
#               EOT
#               EOF

#   tags = {
#     Name = "${var.project-name}-blue-instance"
#   }
# }

# Create the green instance in the private app subnet az2
# resource "aws_instance" "green_instance" {
#   ami           = var.ami_id
#   instance_type = var.instance_type
#   subnet_id     = module.vpc.public_subnet_az2_id
#   associate_public_ip_address = true
#   vpc_security_group_ids = [module.security_group.ec2_security_group_id]
#   key_name = var.key-pair

#   user_data = <<-EOF
#               #!/bin/bash
#               sudo yum update -y
#               sudo yum install -y httpd
#               sudo systemctl start httpd
#               sudo systemctl enable httpd

#               # Tạo file index.html với CSS
#               cat <<EOT >> /var/www/html/index.html
#               <!DOCTYPE html>
#               <html lang="en">
#               <head>
#                   <meta charset="UTF-8">
#                   <meta name="viewport" content="width=device-width, initial-scale=1.0">
#                   <title>Green Deployment v1.0</title>
#                   <style>
#                       body {
#                           font-family: Arial, sans-serif;
#                           background-color: #f0f8ff;
#                           margin: 0;
#                           padding: 0;
#                           display: flex;
#                           justify-content: center;
#                           align-items: center;
#                           height: 100vh;
#                       }
#                       .container {
#                           text-align: center;
#                           background-color: #4CAF50;
#                           padding: 20px;
#                           border-radius: 10px;
#                           box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
#                           color: white;
#                       }
#                       h1 {
#                           font-size: 2.5em;
#                       }
#                       p {
#                           font-size: 1.2em;
#                       }
#                   </style>
#               </head>
#               <body>
#                   <div class="container">
#                       <h1>Welcome to Green Deployment v1.0</h1>
#                       <p>This is a static page served from an EC2 instance with enhanced styling!</p>
#                   </div>
#               </body>
#               </html>
#               EOT
#               EOF

#   tags = {
#     Name = "${var.project-name}-green-instance"
#   }
# }


module "vpc" {
  source                    = "../modules/base/vpc" 
  region                    = var.region 
  project-name              = var.project-name 
  vpc-cidr                  = var.vpc-cidr
  public-subnet-az1         = var.public-subnet-az1
  public-subnet-az2         = var.public-subnet-az2
  private-app-subnet-az2    = var.private-app-subnet-az2
  private-app-subnet-az1    = var.private-app-subnet-az1
  private-data-subnet-az1   = var.private-data-subnet-az1
  private-data-subnet-az2   = var.private-data-subnet-az2
  private-data-subnet-az3   = var.private-data-subnet-az3
}

module "rds" {
  source = "../modules/base/rds"
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id
  private_data_subnet_az3_id = module.vpc.private_data_subnet_az3_id
  rds_cluster_security_group_id = module.security_group.rds_security_group_id
}
# module "nat_gateway" {
#   source                      = "../modules/base/NAT gateways"
#   vpc_id                      = module.vpc.vpc_id
#   public_subnet_az1_id        = module.vpc.public_subnet_az1_id
#   public_subnet_az2_id        = module.vpc.public_subnet_az2_id
#   private_app_subnet_az1_id   = module.vpc.private_app_subnet_az1_id
#   private_app_subnet_az2_id   = module.vpc.private_app_subnet_az2_id
#   private_data_subnet_az1_id  = module.vpc.private_data_subnet_az1_id
#   private_data_subnet_az2_id  = module.vpc.private_data_subnet_az2_id
#   internet_gateway            = module.vpc.internet_gateway
# }

module "security_group" {
  source = "../modules/base/security"
  vpc_id = module.vpc.vpc_id
}

# module "application_load_balancer" {
#   source = "../modules/base/alb"
#   vpc_id = module.vpc.vpc_id
#   project-name = var.project-name
#   public-subnet-az1-id = module.vpc.public_subnet_az1_id
#   public-subnet-az2-id = module.vpc.public_subnet_az2_id
#   alb-security-group-id = module.security_group.alb_security_group_id
#   instance-blue-id = aws_instance.blue_instance.id
#   instance-green-id = aws_instance.green_instance.id
#   production = var.production
# }

