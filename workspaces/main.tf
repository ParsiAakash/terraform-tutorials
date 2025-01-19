provider "aws" {
    region = "ap-south-1"
}

variable "ami" {
    description = "This is AMI"
}

variable "instanceType" {
    description = "This is Instance Type"
    type = map(string)
    default = {
        "dev": "t2.micro",
        "UAT": "t2.micro",
        "prod": "t2.micro"
    }
}

module "ec2_any_name" {
    source = "./modules/ec2_instance"
    # passing variables needed for the module
    amiId = var.ami 
    # instanceType = var.instanceType
    instanceType = lookup(var.instanceType, terraform.workspace, "t2.micro") # this is to define that in the instanceType map look for the key which resolves to terraform.workspace (in our case it resolves to either dev, UAT, prod)
}
