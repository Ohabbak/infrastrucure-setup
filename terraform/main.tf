terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "tfbackend-stg"
    key            = "terraform.tfstate"
    #dynamodb_table = "terraform-state-lock"
    region         = "us-west-1"
  }


}
 

provider "aws" {
  region = "us-west-1"  
}


resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "nat_gateway"
  }
}