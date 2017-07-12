# Terraform Infrastructure for AWS

This solution uses terraform to deploy an AWS infrastrucure that creates an
AWS Instance, and creates an image out of it. This instances comes with a small script that will pull the web page from the s3 bucket into a newly created AMI.

It will create an autoscaling policy for that instance and passes it through an
Application Load Balancer. The application uses the instance previously created.

There is also a Route53 specification which allows the load balancer to have a
given domain name.

In order to run the solution you need to have terraform installed, navigate to the directory and run:
~~~~
terraform apply \
-var ‘access_key={}’ \
-var ‘secret_key={}’ \
-var ‘region={}’ \
-var ‘availability_zones=[{}] \
-var ‘ssh_key_name={}’ \
-var ‘domain_name={}’ \
-var ‘s3_bucket_name_website={}
~~~~
