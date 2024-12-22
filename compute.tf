resource "aws_key_pair" "demo-key" {
    public_key = file("/Users/ramprasad/.ssh/id_rsa.pub")
    key_name = "demo-key"
  
}

resource "aws_instance" "demo-instance" {
    instance_type = var.instance
    ami = var.ami
    key_name = aws_key_pair.demo-key.key_name
    subnet_id = aws_subnet.demo-vpc-public.id
    security_groups = [  ]

    provisioner "remote-exec" {
        inline = [ "sudo apt update" ]

        connection {
          host = self.public_ip
          user = "ubuntu"
          type = "ssh"
          private_key = file("/Users/ramprasad/.ssh/id_rsa")

        }
      
    }

  
}

resource "aws_" "name" {
  
}