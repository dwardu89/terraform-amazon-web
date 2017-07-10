#!/bin/bash
yum update -y
yum install httpd -y

groupadd www
usermod -a -G www ec2-user
chown -R root:www /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} +
find /var/www -type f -exec chmod 0664 {} +

aws s3 sync s3://${bucket_name}/ /var/www/html/ --recursive

service httpd start
chkconfig httpd on
