
resource "aws_launch_configuration" "as_conf" {
  name          = "web_launch_config_123"
  image_id      = "${aws_ami_from_instance.webpage_infra.id}"
  instance_type = "t2.micro"
  depends_on = ["aws_ami_from_instance.webpage_infra"]
  key_name      = "${var.ssh_key_name}"
  user_data       = "${data.template_file.init_shell.rendered}"
  # Security group
  security_groups = ["${aws_security_group.default.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.web_instance_profile.id}"

  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
}
}


resource "aws_autoscaling_group" "web_server_as_group" {
name                 = "ws-as-group-${123}"
  vpc_zone_identifier = ["${aws_subnet.main.*.id}"]
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  min_size             = 1
  max_size             = 5
  target_group_arns =  ["${aws_alb_target_group.albtf.id}"]
  depends_on = ["aws_launch_configuration.as_conf"]
  lifecycle {
    create_before_destroy = true
  }


  tags = [
    {
      key                 = "Name"
      value               = "web-asgrp"
      propagate_at_launch = true
    },
    {
      key                 = "CreatedFrom"
      value               = "Terraform"
      propagate_at_launch = true
    },
  ]

}

resource "aws_alb_target_group_attachment" "original_web_infra" {
  target_group_arn = "${aws_alb_target_group.albtf.arn}"
  target_id        = "${aws_instance.webpage_infra.id}"
}



resource "aws_autoscaling_policy" "web_server_as_policy_decrease" {
  name                   = "web_server_as_policy_decrease_${123}"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300

  autoscaling_group_name = "${aws_autoscaling_group.web_server_as_group.name}"
}

resource "aws_cloudwatch_metric_alarm" "lowDemand" {
  alarm_name          = "terraform-low-demand-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web_server_as_group.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.web_server_as_policy_decrease.arn}"]
}



resource "aws_autoscaling_policy" "web_server_as_policy_increase" {
  name                   = "web_server_as_policy_increase_${123}"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300

  autoscaling_group_name = "${aws_autoscaling_group.web_server_as_group.name}"
}

resource "aws_cloudwatch_metric_alarm" "highDemand" {
  alarm_name          = "terraform-high-demand-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web_server_as_group.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.web_server_as_policy_increase.arn}"]
}
