resource "aws_alb_target_group" "albtf" {
  name     = "tf-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
}

resource "aws_alb" "main" {
  name            = "tf-alb-main"
  subnets         = ["${aws_subnet.main.*.id}"]
  security_groups = ["${aws_security_group.default.id}"]
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.albtf.id}"
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "alb_tg_a" {
  target_group_arn = "${aws_alb_target_group.albtf.arn}"
  target_id        = "${aws_instance.webpage_infra.id}"
  port             = 80
}
