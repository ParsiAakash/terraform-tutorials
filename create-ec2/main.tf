provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "created_by_terraform" {
    ami = "ami-053b12d3152c0cc71"
    instance_type = "t2.micro"
}


#  multi region of same cloud , if you want your resources to be created in multiple regions of aws

provider "aws" {
    alias = "mumbai"
    region = "ap-south-1"
}

provider "aws" {
    alias = "virginia"
    region = "us-east-1"
}

resource "aws_instance" "mumbai_instance" {
    ami = "ami-00bb6a80f01f03502"
    instance_type = "t2.micro"
    provider = aws.mumbai
}

resource "aws_instance" "virginia_instance" {
    ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"
    provider = aws.virginia
}


# instead of hardcoding the values like ami, instance type, we can use variables

variable "instanceType" {
    description = "This is a variable used to describe instanceType"
    type = string
    default = "t2.micro"
}

variable "amiId" {
    description = "This is a variable used to describe amiId"
    type = string
}

# create an instance using input variables
resource "aws_instance" "instance_with_variables" {
    ami = var.amiId
    instance_type = var.instanceType
}

# output variable which exposes the IP of the created instance

output "Ip_of_the_instance" {
    description = "Public IP of the instance"
    value = aws_instance.instance_with_variables.public_ip
}