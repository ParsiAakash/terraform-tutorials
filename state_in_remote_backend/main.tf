provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "instance_3" {
    ami = "ami-053b12d3152c0cc71"
    instance_type = "t2.micro"
}

resource "aws_dynamodb_table" "terraform_lock" {
    name = "terraform-lock"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
}