

resource "aws_instance" "demo-instance" {
    instance_type = var.instance
    ami = var.ami
    key_name = "Cloudops"
    for_each = {for key, subnet in var.subnets : key => subnet if subnet.public == true } 
    subnet_id = aws_subnet.demo-subnets[each.key].id
    security_groups = [ aws_security_group.demo-sg.id ]
    

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

resource "aws_security_group" "demo-sg" {
    name = "demo-sg"
    description = "demo-sg"
    vpc_id = aws_vpc.demo-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        cidr_blocks = [ "0.0.0.0/0" ]
        protocol = "tcp"
        
    }

    egress {
        from_port = 0
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
        protocol = "-1"
    }
  
}