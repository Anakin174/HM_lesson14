provider "aws" {
  region = "us-east-2"
}

variable "image_id" {
  default = "ami-0bbe28eb2173f6167"
}


variable "security_group" {
  default = ["sg-09ce11f213f8c6b3c"]
}

variable "subnet_id" {
  default = "subnet-4a8eb730"
}

variable "ssh-key" {
  default = "~/.ssh/id_rsa"
 # default = "file("~/.ssh/id_rsa")}"
}


resource "aws_instance" "build_instance" {
  ami = "${var.image_id}"
  instance_type = "t2.micro"
  key_name = "${var.ssh-key}"
#  security_groups = [""]
  vpc_security_group_ids = "${var.security_group}"
  subnet_id = "${var.subnet_id}"
  tags = {
    Name = "build"
  }
  user_data = <<EOF
#!/bin/bash
sudo apt update && sudo apt install -y maven awscli
git clone https://github.com/Anakin174/boxfuse.git
cd boxfuse && mvn clean package
aws s3 cp target/hello-1.0.war s3://boxfuse-test-web
EOF
}

resource "aws_instance" "prod_instance" {
  ami = "${var.image_id}"
  instance_type = "t2.micro"
  key_name = "${var.ssh-key}"
  vpc_security_group_ids = "${var.security_group}"
  subnet_id = "${var.subnet_id}"
  tags = {
    Name = "prod"
  }
  user_data = <<EOF
#!/bin/bash
sudo apt update && sudo apt install -y openjdk-8-jdk tomcat8 awscli
aws s3 cp s3://boxfuse-test-web/hello-1.0.war /tmp/hello-1.0.war
sudo mv /tmp/hello-1.0.war /var/lib/tomcat8/webapps/hello-1.0.war
sudo systemctl restart tomcat8
EOF
}