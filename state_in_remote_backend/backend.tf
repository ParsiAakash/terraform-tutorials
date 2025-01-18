terraform {
    backend "s3" {
        bucket = "aakash-terraform-bucket-2"
        key    = "aakash/terraform.tfstate"
        region = "ap-south-1"
        dynamodb_table = "terraform_lock"
    }
}
