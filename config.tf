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

resource "aws_key_pair" "amazon" {
  key_name = "amazon"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCcmFwu15kFVZ2RKQbzZzu/g5je1SJ57iN9CdTgm/321skFrqCMtBF/ybae8aemjRLaZemLK8QmfBc3dg9EU9CAjJXO1QZbL0r7wpHR9/Ot/q5kcppqaa8vJuuQaioNxw+8j84gialaVNT/d8Cpm1b0IbE9e6UKjcTUdnBKKIYij8mFQX1NUadxizsYGo6YZQYY8+hTAH8URKQ7u6U4C9m9hX9seOo29BFMeMffX0hUV4S3NmKY85KJuK2xseVzv93gEh+oz93y5dREupAiLjXvteCLY/i6qCpcKl4lvquA3yZWCp0Y6pxv6lZhrF8m17FTzsU8UiXyPmz4s0jmNRnJ root@ip-172-31-23-231"
}

resource "aws_instance" "build_instance" {
  ami = "${var.image_id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.amazon.key_name}"
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
EOF
}

resource "aws_s3_bucket_object" "war" {
  bucket = "boxfuse-test-web"
  key = "hello.war"
  source = "${file("${aws_instance.build}/home/boxfuse/target/hello-1.0.war")}"
  etag = '${md5(file("${aws_instance.build}/home/boxfuse/target/hello-1.0.war"))}'
}


resource "aws_instance" "prod_instance" {
  ami = "${var.image_id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.amazon.key_name}"
  vpc_security_group_ids = "${var.security_group}"
  subnet_id = "${var.subnet_id}"
  tags = {
    Name = "prod"
  }
  user_data = <<EOF
#!/bin/bash
sudo apt update && sudo apt install -y openjdk-8-jdk tomcat8 awscli
cd /var/lib/tomcat8/webapps
wget https://s3.us-east-2.amazonaws.com/boxfuse-test-web/hello-1.0.war
sudo systemctl restart tomcat8
EOF
}