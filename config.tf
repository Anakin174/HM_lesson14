provider "aws" {
  region = "us-east-2"
}

variable "image_id" {
  default = "ami-0bbe28eb2173f6167"
}

variable "vpc_id" {
  default = "vpc-ea13c881"
}

resource "aws_instance" "build_instance" {
  ami = "${var.image_id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.amazon.key_name}"
  vpc_security_group_ids = ["${aws_security_group.Open.id}"]
  subnet_id = "${var.subnet_id}"
  user_data = <<EOF
#!/bin/bash
sudo apt update && sudo apt install -y maven awscli
git clone https://github.com/Anakin174/boxfuse.git
cd boxfuse && mvn clean package

EOF

}