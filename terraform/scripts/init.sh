#!/bin/bash
yum update -y
yum install httpd -y


service httpd start
chkconfig httpd on
groupadd www
usermod -a -G www ec2-user
chown -R root:www /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} +
find /var/www -type f -exec chmod 0664 {} +

sh -c $'echo "Hello" > /var/www/html/index.html'
sh -c $'echo "I\'m Alive" > /var/www/html/healthy.html'
