
variable "access_key" {}
variable "secret_key" {}
variable "region" {}
variable "public_key_path" {}
variable "aws_key_name" {}



provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.aws_key_name}"
  public_key= "${file(var.public_key_path)}"
}


resource "aws_instance" "web" {
  ami = "ami-0b59bfac6be064b78"
  key_name = "${aws_key_pair.auth.key_name}"
  instance_type = "t2.micro"
  provisioner "local-exec" {
    command = "echo ${aws_instance.web.public_ip} > ip_address.txt"
    }
  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install httpd",
      "sudo yum -y install mysql",
      "sudo service httpd start",
    ]
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.web.id}"
}


output "ip" {
  value = "${aws_eip.ip.public_ip}"
}
