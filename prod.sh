#!/bin/bash
sudo apt update
sudo apt install openjdk-8-jdk tomcat8 -y
cd /var/lib/tomcat8/webapps
wget https://boxfuse-test-web.s3.us-east-2.amazonaws.com/hello-1.0.war
sudo systemctl restart tomcat8.service