
resource "aws_lb" "nextcloud" {
  name               = "nextcloud-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-alb.id]
  subnets            = [aws_subnet.sp-sub-pub-1a.id, aws_subnet.sp-sub-pub-1b.id]

  enable_deletion_protection = false
  internal                   = false


  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_target_group" "tg_nextcloud" {
  name_prefix          = "tg-nc-"
  vpc_id               = aws_vpc.sp-vpc.id
  port                 = 80
  protocol             = "HTTP"
  target_type          = "instance"
  deregistration_delay = 30

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 10
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 3
}


  tags = {
    Name = "${var.project_name}-tg"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.nextcloud.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_nextcloud.arn
  }
}

resource "aws_lb_target_group_attachment" "attach_ec2" {
  target_group_arn = aws_lb_target_group.tg_nextcloud.arn
  target_id        = aws_instance.sp-ec2.id
  port             = 80
}



output "alb_url" {
  description = "DNS público do Application Load Balancer"
  value       = aws_lb.nextcloud.dns_name
}
