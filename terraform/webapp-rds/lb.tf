# application load balancer 
locals {
  name = "${var.cluster_name}-${var.task_name}"
}

data "aws_route53_zone" "zone" {
  name         = var.hosted_zone_name
  private_zone = false
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.zone.id

  subject_alternative_names = var.subject_alternative_names

  tags = var.tags
}

resource "aws_lb" "alb" {
  name               = "${local.name}-lb"
  load_balancer_type = "application"
  subnets            = tolist(module.network.public_subnet_ids)
  security_groups    = [aws_security_group.alb.id]
  tags               = merge({ Name = local.name }, var.tags)
}

resource "aws_security_group" "alb" {
  name_prefix = substr(local.name, 0, 6)
  description = "load balancer sg for ingress and egress to ${var.task_name}"
  vpc_id      = module.network.vpc_id

  tags = merge({ Name = local.name }, var.tags)


  ingress {
    description = "HTTP from world"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from world"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow outbound traffic to the world"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
    target_group_arn = aws_lb_target_group.default.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = module.acm.this_acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

resource "aws_lb_target_group" "default" {
  name_prefix = substr(local.name, 0, 6)
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.network.vpc_id
}
