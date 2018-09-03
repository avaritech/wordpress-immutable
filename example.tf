
variable "access_key" {}
variable "secret_key" {}
variable "region" {}
variable "public_key_path" {}
variable "aws_key_name" {}
variable "ssh_IPs" {
  default = ["0.0.0.0/0"]
}
variable "private_key_path" {}
variable "serversToManageFile" {}



provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

###########VPC AND NETWORKING################
# Create a VPC
resource "aws_vpc" "default" {
  cidr_block = "172.17.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# VPC route
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet in the VPC
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "172.17.1.0/24"
  map_public_ip_on_launch = true
}

############SECURITY GROUP####################
# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "wordpress_SG"
  description = "Used for wordpress/web access"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.ssh_IPs}"
  }

  # HTTP access from the world
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#instance stuff
resource "aws_key_pair" "auth" {
  key_name   = "${var.aws_key_name}"
  public_key= "${file(var.public_key_path)}"
}


resource "aws_instance" "web" {
  #need to set tags
  ami = "ami-0b59bfac6be064b78"
  key_name = "${aws_key_pair.auth.key_name}"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.default.id}"
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file(var.private_key_path)}"
    }
#    inline = [
#      "sudo yum -y update",
#      "sudo yum -y install httpd",
#      "sudo yum -y install mysql mysql-server",
#      #"sudo service httpd start",
#      "sudo service mysqld start"
#    ]
  }
}

resource "aws_eip" "ip" {
provisioner "local-exec" {     # public IP is unneeded since we'll have elastic IP. commenting out for now.
  #command = "echo [web] > ${var.serversToManageFile}"
  command = "echo [web] > ${var.serversToManageFile} \necho ${aws_eip.ip.public_ip} >> ${var.serversToManageFile}"
  }
  instance = "${aws_instance.web.id}"
}


#this still wants to run on startup. Need to find a solution
#resource "null_resource" "ansible" {
#  triggers {
#    key = "${uuid()}"
#  }
#  provisioner "local-exec" {
#    command = "ansible-playbook -i ${var.serversToManageFile} -u ec2-user -K setup-wordpress.yml --private-key ${file(var.private_key_path)}"
#  }
#}

output "ip" {
  value = "${aws_eip.ip.public_ip}"
}
output "Ansible command to run"{
  value = "ansible-playbook -i ${var.serversToManageFile} -u ec2-user -K setup-wordpress.yml --private-key ${file(var.private_key_path)}"
}
