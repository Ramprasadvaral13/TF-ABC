resource "aws_launch_template" "demo-lt" {
  name          = "aws-launch-template"
  image_id      = var.ami
  instance_type = var.instance
  key_name      = "Cloudops"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.demo-sg.id]
  }

}

