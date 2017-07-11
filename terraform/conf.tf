
variable "access_key" {
  description = "The access key used to communicate with AWS"
}
variable "secret_key" {
  description = "The secret key used to communicate with AWS"
}
variable "region" {
  default = "eu-west-2"
  description = "The region that will be used to run the terraform script."
}
variable "availability_zones" {
  default = ["eu-west-2a", "eu-west-2b"]
  description = "The availability zones belonging to the region."
}
variable "ssh_key_name" {
  description = "The name of the Key Pair that will be linked to instances."
}
variable "domain_name" {
  default = "example.com"
  description = "The domain name used to instruct Route53 to point to."
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "s3_bucket_name_website" {
  description = "The S3 bucket to use."
}

data "template_file" "init_shell" {
  template = "${file("templates/init.sh")}"

  vars {
    bucket_name = "${var.s3_bucket_name_website}"
    region = "${var.region}"
  }
}
output "rendered" {
  value = "${data.template_file.init_shell.rendered}"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
