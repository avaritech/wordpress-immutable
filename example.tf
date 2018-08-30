
variable "access_key" {}
variable "secret_key" {}
variable "region" {}


provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "TFexample" {
  ami           = "ami-0cf31d971a3ca20d6"
  instance_type = "t2.micro"
}


resource "aws_eip" "ip" {
  instance = "${aws_instance.TFexample.id}"
}
