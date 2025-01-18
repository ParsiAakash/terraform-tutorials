output "public_ip_address" {
    value = aws_instance.instance_with_variables.public_ip
}