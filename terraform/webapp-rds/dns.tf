resource "aws_route53_record" "app_url" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "db_url" {
  zone_id = var.hosted_zone_id
  name    = "${var.task_name}-db"
  type    = "A"
  alias {
    name                   = module.db.this_db_instance_address
    zone_id                = module.db.this_db_instance_hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "bastion" {
  zone_id = var.hosted_zone_id
  name    = "bastion-${var.stage}-${var.region}"
  type    = "A"
  ttl = 300
  records = [aws_eip.eip.public_ip]
}
