resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "deployer-key"
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_instance" "instance" {
  ami           = "ami-0d52744d6551d851e"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name

  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y software-properties-common
              sudo apt-add-repository --yes --update ppa:ansible/ansible
              sudo apt-get install -y ansible
              sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt-get update
              sudo apt-get install -y docker-ce
              sudo usermod -aG docker $USER
              sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              EOF

  tags = {
    Name = "terraform-ec2"
  }
}

resource "aws_security_group" "sg" {
  name = "terraform-ec2-sg"
}

locals {
  ingress_ports = ["22", "80", "8080", "3306", "5432"]
}

resource "aws_security_group_rule" "ingress_rules" {
  for_each = toset(local.ingress_ports)

  type              = "ingress"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

output "ec2_private_key" {
  description = "The private key data in PEM format"
  value       = tls_private_key.key.private_key_pem
  sensitive   = true
}
