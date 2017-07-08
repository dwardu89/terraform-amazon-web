

data "aws_ami" "awslinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-2017.03.1.20170623-x86_64-gp2"]
  }

  owners = ["137112412989"] # Canonical
}


resource "aws_instance" "webpage_infra" {
  ami           = "${data.aws_ami.awslinux.id}"
  instance_type = "t2.micro"
  key_name      = "${var.ssh_key_name}"
  security_groups = ["web-dmz"]


  provisioner "local-exec" {
    command = "echo ${aws_instance.webpage_infra.public_ip} > ip_address.txt"
  }

  tags {
   Name = "MyWebServer"
 }

  provisioner "file" {
    source      = "scripts/init.sh"
    destination = "/tmp/init.sh"

    connection {
      type     = "ssh"
      port     = "22"
      user     = "ec2-user"
      private_key = "${file(var.ssh_key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/init.sh",
      "/tmp/init.sh",
    ]

    connection {
      type     = "ssh"
      port     = "22"
      user     = "ec2-user"
      private_key = "${file(var.ssh_key_path)}"
    }
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.webpage_infra.id}"
  depends_on = ["aws_instance.webpage_infra"]
}

output "eip-address" {
  value = "${aws_eip.ip.public_ip}"
}
