provider "aws" {
    region = "ap-south-1"
}

variable "amiId" {
    description = "This is a variable which states the amiID"
}

variable "instanceType" {
    description = "This states the instance type of the ec2"
}

resource "aws_instance" "ec2_example" {
    ami = var.amiId
    instance_type = var.instanceType
}