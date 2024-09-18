
provider "aws" {
    region="us-east-1"
}


resource "aws_vpc" "vpc" {
    cidr_block=var.vpc_cidr_block  
    tags={

      Name="${var.env}-vpc"
    }
}

module "subnet-igw-rt" {
    source="./modules/subnet"
    vpc_id=aws_vpc.vpc.id
    subnet_cidr_block=var.subnet_cidr_block
    env= var.env
    avail_zone=var.avail_zone
}

module "ec2-secgrp-key" {
    source="./modules/server"
    vpc_id=aws_vpc.vpc.id
    instance_type=var.instance_type
    my-ip=var.my-ip
    env= var.env
    avail_zone=var.avail_zone
    subnet_id=module.subnet-igw-rt.subnet-details.id
}

terraform{
    backend "s3" {
        bucket = "terraform-modules-task"
        key="tf-state/terraform.tfstate"
        region="us-east-1"

    }
    
}
