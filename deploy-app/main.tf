variable "region" {
    default = "ap-south-1"
}

provider "aws" {
    region = var.region
}

variable "cidr_vpc" {
    default = "10.0.0.0/16"
}

variable "cidr_subnet" {
    default = "10.0.0.0/24"
}

resource "aws_vpc" "vpc_example" {
    cidr_block = var.cidr_vpc
}

resource "aws_key_pair" "ssher" {
    key_name   = "Terraform-Aakash"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_subnet" "subnet_example" {
    vpc_id     = aws_vpc.vpc_example.id
    cidr_block = var.cidr_subnet
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "subnet_example"
    }
}

resource "aws_internet_gateway" "igw_example" {
    vpc_id = aws_vpc.vpc_example.id
    
    tags = {
        Name = "igw_example"
    }
}

resource "aws_route_table" "rt_example" {
    vpc_id = aws_vpc.vpc_example.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_example.id
    }

    tags = {
        Name = "rt_example"
    }
}

resource "aws_route_table_association" "associate_rt_subnet" {
    subnet_id      = aws_subnet.subnet_example.id
    route_table_id = aws_route_table.rt_example.id
}

resource "aws_security_group" "sg_example" {
    name        = "sg_example_internet"
    description = "outbound is not restricted, inbound is open for SSH(22), port 80"
    vpc_id      = aws_vpc.vpc_example.id
    
    ingress {
        description = "SSH port"
        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }

    ingress {
        description = "Port no 80, to run our app"
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }

    egress {
        description = "Open to access anything"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "sg_example"
    }
}

resource "aws_instance" "ec2_example" {
    ami = "ami-053b12d3152c0cc71"
    instance_type = "t2.micro"
    key_name = aws_key_pair.ssher.key_name
    vpc_security_group_ids = [aws_security_group.sg_example.id]
    subnet_id = aws_subnet.subnet_example.id
    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = file("~/.ssh/id_rsa")
        host = self.public_ip
    }

    provisioner "file" {
        source = "app.py"
        destination = "/home/ubuntu/app.py"
    }

    provisioner "remote-exec" {
        inline = [ 
            "echo 'Hello from Terrafrom !!'",
            "sudo apt update -y", # update the packages of ubuntu with yes as input
            "sudo apt-get install -y python3-pip", # package installation
            "cd /home/ubuntu",
            "sudo pip3 install flask",
            "sudo python3 app.py &"
        ]
    }
}