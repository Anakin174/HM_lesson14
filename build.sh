#!/bin/bash
sudo apt update && sudo apt install -y maven awscli
git clone https://github.com/Anakin174/boxfuse.git
cd boxfuse && mvn clean package
cd ~
mkdir .aws && cd .aws
cd .aws
wget https://s3.us-east-2.amazonaws.com/bucket-with-your-config/config
wget https://s3.us-east-2.amazonaws.com/bucket-with-your-credentials/credentials
cd /boxfuse/target
aws s3 cp hello-1.0.war s3://boxfuse-test-web