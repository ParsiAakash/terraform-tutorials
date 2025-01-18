provider "aws" {
    region = var.aws_location
}

resource "aws_instance" "instance_with_variables" {
    instance_type = var.instanceType
    ami = var.amiId
    # subnet_id =  
}