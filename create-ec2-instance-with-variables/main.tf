provider "aws" {
    region = var.aws_location
}

module "ec2_instance" {
    source = "./modules/ec2_instance"
    amiId = "ami-00bb6a80f01f03502"
    instanceType = "t2.micro"
    aws_location = var.aws_location
}