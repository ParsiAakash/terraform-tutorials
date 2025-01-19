provider "aws" {
    region = "ap-south-1"
}

provider "vault" {
    address = "http://3.7.71.237:8100"
    skip_child_token = true
    auth_login {
        path = "auth/approle/login"
        parameters = {
            role_id = "8af9eba9-a86a-6010-5ef4-622a1983bd4b"
            secret_id = "388dbead-1277-b995-dbd6-753fa7afdd5f"
        }
    }
}


data "vault_kv_secret_v2" "example" {
    mount = "kv"
    name  = "kv-secret"
}

#till now the hashicorp vault and terraform is integrated

resource "aws_instance" "ec2_example" {
    ami = "ami-00bb6a80f01f03502"
    instance_type = "t2.micro"
    tags = {
      secret = data.vault_kv_secret_v2.example.data["username"]
    }
}
