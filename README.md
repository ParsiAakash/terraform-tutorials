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
    