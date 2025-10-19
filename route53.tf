# Hosted Zone
resource "aws_route53_zone" "main" {
  name = "cloud.flog.br"
}


resource "aws_route53_record" "root_nextcloud" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_lb.nextcloud.dns_name
    zone_id                = aws_lb.nextcloud.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "nextcloud" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "nextcloud"
  type    = "A"

  alias {
    name                   = aws_lb.nextcloud.dns_name
    zone_id                = aws_lb.nextcloud.zone_id
    evaluate_target_health = true
  }
}
