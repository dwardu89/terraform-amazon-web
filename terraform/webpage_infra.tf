

data "aws_ami" "awslinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-2017.03.1.20170623-x86_64-gp2"]
  }

  owners = ["137112412989"] # Canonical
}


resource "aws_instance" "webpage_infra" {
  ami             = "${data.aws_ami.awslinux.id}"
  instance_type   = "t2.micro"
  key_name        = "${var.ssh_key_name}"
  user_data       = "${file("scripts/init.sh")}"
  subnet_id       = "${aws_subnet.main.0.id}"
  provisioner "local-exec" {
    command = "echo ${timestamp()}"
  }

  tags {
   Name = "MyWebServer"
 }
}

resource "aws_ami_from_instance" "webpage_infra" {
  name               = "terraform-webserver-${123}"
  source_instance_id = "${aws_instance.webpage_infra.id}"
}

output "aws-ami-id" {
  value = "AMI ID - ${aws_ami_from_instance.webpage_infra.id}"
}

output "aws-instance-id" {
  value = "${aws_instance.webpage_infra.id}"
}
