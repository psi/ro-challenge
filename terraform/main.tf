provider "aws" {
  region = "eu-central-1"
}

# Configure VPC with publicly routed subnet
resource "aws_vpc" "primary" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
}

resource "aws_internet_gateway" "primary" {
    vpc_id = "${aws_vpc.primary.id}"
}

resource "aws_subnet" "web_servers" {
  vpc_id = "${aws_vpc.primary.id}"
  cidr_block = "10.0.1.0/24"
}

resource "aws_route_table" "web_servers" {
  vpc_id = "${aws_vpc.primary.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.primary.id}"
  }
}

resource "aws_route_table_association" "web_servers_public" {
  subnet_id = "${aws_subnet.web_servers.id}"
  route_table_id = "${aws_route_table.web_servers.id}"
}

# Configure security group to allow SSH and port 80
resource "aws_security_group" "web_server" {
  name = "web_server"
  description = "Allow inbound access on port 22 and 80"

  vpc_id = "${aws_vpc.primary.id}"
}

resource "aws_security_group_rule" "web_server_port_22" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web_server.id}"
}

resource "aws_security_group_rule" "web_server_port_80" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web_server.id}"
}

resource "aws_security_group_rule" "web_server_allow_all_out" {
  type = "egress"
  from_port = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web_server.id}"
}

# Create an SSH keypair to use for provisioning the instance
resource "tls_private_key" "provisioner" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "provisioner" {
  public_key = "${tls_private_key.provisioner.public_key_openssh}"
}

# Create the instance to serve Hello app
resource "aws_instance" "web_server" {
  ami = "ami-0cf8fa6a01bb07363"
  instance_type = "t2.micro"

  key_name = "${aws_key_pair.provisioner.key_name}"

  associate_public_ip_address = true

  subnet_id = "${aws_subnet.web_servers.id}"
  vpc_security_group_ids = ["${aws_security_group.web_server.id}"]

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${tls_private_key.provisioner.private_key_pem}"
  }

  provisioner "file" {
    source = "../hello_app"
    destination = "/tmp/hello_app"
  }

  provisioner "remote-exec" {
    script = "provision.sh"
  }
}

output "hello_url" {
  value = "http://${aws_instance.web_server.public_ip}/hello"
}
