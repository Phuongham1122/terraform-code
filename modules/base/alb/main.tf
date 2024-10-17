# create application load balancer
resource "aws_lb" "application_load_balancer" {
  name               = "${var.project-name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb-security-group-id]
  subnets            = [var.public-subnet-az1-id, var.public-subnet-az2-id]
  enable_deletion_protection = false

  tags   = {
    Name = "${var.project-name}-alb"
  }
}

# create target group
resource "aws_lb_target_group" "blue_target_group" {
  name        = "${var.project-name}-blue-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "green_target_group" {
  name        = "${var.project-name}-green-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 5 
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "blue_instance_attachment" {
  target_group_arn = aws_lb_target_group.blue_target_group.arn
  target_id        = var.instance-blue-id
  port             = 80
}

resource "aws_lb_target_group_attachment" "green_instance_attachment" {
  target_group_arn = aws_lb_target_group.green_target_group.arn
  target_id        = var.instance-green-id
  port             = 80
} 

# create a listener on port 80 with redirect action
# ALB trỏ tới blue là môi trường production
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    # target_group_arn = aws_lb_target_group.blue_target_group.arn 
    target_group_arn = var.production == "green" ? aws_lb_target_group.green_target_group.arn : aws_lb_target_group.blue_target_group.arn 
  }
}

#Chuyển hướng ALB tới green
resource "aws_lb_listener_rule" "green_rule" {
  listener_arn = aws_lb_listener.alb_http_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = var.production == "green" ? aws_lb_target_group.green_target_group.arn : aws_lb_target_group.blue_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/app/*"]
    }
  }
}
