
resource "aws_lb" "nextcloud" {
  name               = "nextcloud-alb"
  load_balancer_type = "application"
  security_groups    = [aws]
  subnets            = aws_subnet.sp-sub-pub.id

  enable_deletion_protection = false
  internal                   = false

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_target_group" "tg_nextcloud" {
  name_prefix          = "tgnextcloud-"
  vpc_id               = aws_vpc.sp-vpc.id
  port                 = 80
  protocol             = "HTTP"
  target_type          = "instance"
  deregistration_delay = 30

  health_check {
    enabled             = true
    interval            = 10
    path                = "/api/versao"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
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


output "alb_url" {
  description = "DNS público do Application Load Balancer"
  value       = aws_lb.nextcloud.dns_name
}
