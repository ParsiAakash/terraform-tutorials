# terraform-tutorials
In the process of learning Terraform on AWS cloud, I have made this project


After every `terraform apply` command gets executed the state file gets generated, this is like a terraform notes in which it keeps having a track of what has been done till now, when you again run terraform apply, it will check this records and then act on it
`terraform init` Initialize terraform with cloud provider
`terraform plan` its like a preview for you so that you can just re-check before implementing it 
`terraform apply` this will apply all the configurations created by you
`terraform destroy` will destroy all instances / created by `terraform apply`
`provider` this is the cloud provider on which you want the whole config to be applied
`variables` this is used to parameterize the code, so that you can inject values into it, instead of hardcoding it
    `input` if you pass any variable to terraform it is called input variables
    `output` if you want to print something after terraform apply , like ip of the instance created .. etc, this is called output variables
`Conditional expressions` this is same like a ternary operator, if true execute a thing else the other
`terraform.tfvars` this is a file which is equivalent to .env file of the program, which contains the configuration, variable information, sensitive information, you can put this in .gitignore file
`modules` this is used to reuse the existing module just by passing the variables needed to it
`terraform registry` this is a publicly available registry for terraform from which we can clone any module and use it for further development
`state file` this is an audit file that is created and maintained by terraform to keep track of all the things we have done 
till now using terraform if we wanted to update / edit already created instance ,
terraform should know that its an update not a create request so it maintains all the things done
`cons of the state file` it can record / store any information in the state file even the sensitive information
`how to overcome state file issues` we can use remote backend, we can upload / use s3 bucket to store the state file and read and write into that bucket everytime the state file changes

`lock file` this is used to handle the concurrency of the commands, if 2 users want to execute the terraform apply at the same instance, only 1 user can achieve the lock on the file and the other user has to wait until that user is done 

`To create a EC2 instance which can host a application`

1. Create a VPC & Add CIDR for the VPC
2. Create a Key value pair (Add the public key to the EC2 you are planning to create and SSH into it using the private key) (command: ssh-keygen -t rsa)
3. Create a Subnet in the VPC & Add CIDR for the Subnet 
4. Create a Internet gateway for the VPC.
5. Create a route table for the VPC and add the internet gateway as the destination for the route table
6. Associate the Route table with the subnet to make it public
7. Create the security group with Inbound, outbound requests configuration (In Terrafrom Inbound ~= ingress, outbound ~= egress)
8. Create EC2 instance in the Subnet

`Terraform provisioners`
    `File Provisioners` : this is to copy or move any files from our local to the remote system
    `local exec provisioners`: this is to execute something or write some logs or save logs into a file .. etc , using this you can execute the commands in your machine
    `remote exec provisioners` this is to execute commands in your remote machine 

`Terraform Workspaces`
    Workspaces are used to maintain or reuse the existing IAC for different environments in our organization
    `Example`: Lets say you want a Ec2 machine to be created for Dev, UAT, Prod and the configuration is different, so you would think that I would provide the module to create the EC2 and we can parameterize it but lets say if dev needs `t2.micro` and UAT needs `t2.medium` when you execute dev, the state file records it and when you try to execute again, terraform thinks that you are trying to modify the existing, so it will update the existing, this is caused because there is only 1 state file, to overcome this we use `workspaces`
    so now we can create multiple workspaces using the command `terraform workspace new <env>` example `terraform workspace new dev`
    to switch to any workspace we can use the command `terraform workspace select <env>` example ``terraform workspace select dev`
    to know which workspace you are in use the command `terraform workspace show`
    
`Hashicorp Vault`
    This is a vault where we can store our sensitive information like db passwords, instance secrets .. etc 
    We shall create an EC2 instance and then integrate our hashicorp vault in it 

1. Create an EC2 instance with key value pair of type RSA
2. Login to EC2 machine with the command `ssh -i <path to pem file> ubuntu@<public_ip>`
3. Vault package is not by default available in Ubuntu machine so we install gpg `sudo apt install gpg`
4. Download the signing key to a new keyring `wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg`
5. Verifying the fingerprint `gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint`
6. Add the hashicorp repo to your ubuntu machine `echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list`
7. update the package manager `sudo apt update`
8. Install the vault now `sudo apt install vault`
9. check if vault is successfully installed `vault`
10. start the vault development server `vault server -dev -dev-listen-address="0.0.0.0:8200"`
11. once you start the vault server in your machine, in the console you can see the web address on which the vault is running with port, you have to enable the security group to allow this port for inbound (8200 by default)
12. you can also see a `root token` in the console, once you open the `<ip_address>:<port>` you can select token from the drop down and enter this token into the token field, which will grant you the root access to the vault

now you can see `secret engines`, `access`, `policies`


`secret engines`: This is a store where you can save different types of secrets like key-value pair or kubernetes secret config .. etc
Lets create a KV (key value pair):
1. select the path, this is a path on which you wanted the secret info to be stored inside the machine, the best part is whatever you are storing outside hashicorp vault, its only encryptedly stored, no one can see the decrypted one, only the hashicorp has the decrypted / readable format stored

2. `policies` this is to create a policy for the roles to assign it to role, this is similar to IAM policy of AWS, you cannot create roles thru GUI, you only can create using CLI 
`export VAULT_ADDR='http://0.0.0.0:8200'`
`vault policy write terraform - <<EOF 
path "*" {
  capabilities = ["list", "read"]
}

path "secrets/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}


path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "auth/token/create" {
capabilities = ["create", "read", "update", "list"]
}
EOF`

3. `access` this is to create a role to which we can attach a policy, this is similar to IAM role of AWS, you cannot create roles thru GUI, you only can create using CLI 
`export VAULT_ADDR='http://0.0.0.0:8200'`
`vault write auth/approle/role/terraform     secret_id_ttl=10m     token_num_uses=10     token_ttl=20m     token_max_ttl=30m     secret_id_num_uses=40     token_policies=terraform`

4. you will have to get the role-id of the role created for the policy terraform : `vault read auth/approle/role/terraform/role-id`
5. you will have to get the secret-id of the role created: `vault write -f  auth/approle/role/terraform/secret-id`

now the hashicorp vault is created and we have got the role-id and secret-id with us, now we shall integrate our vault with the terraform

we use `data` as the key word if we wanted to read the data from the source, just like we use the keyword `resource` when we wanted to create anything in the machine
