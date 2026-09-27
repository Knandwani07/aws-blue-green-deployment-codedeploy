#!/bin/bash

dnf install -y httpd ruby wget

systemctl enable httpd
systemctl start httpd

echo "BLUE" > /var/www/html/index.html
echo "OK" > /var/www/html/health.html

cd /tmp
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x install
./install auto

systemctl enable codedeploy-agent
systemctl start codedeploy-agent
