#!/bin/bash
sudo yum update -y
sudo yum install httpd -y

sudo service httpd start

sudo sh -c $'echo "I\'m Alive" > /var/www/html/healthy.html'
