output "web_server"{
    value = aws_instance.my_ec2.public_ip
}
