resource "aws_route53_zone" "thoughtlyifyio" {
  name = "thoughtlyify.io"
}

resource "aws_route53_zone" "thoughtlyifyclick" {
  name = "thoughtlyify.click"
}

resource "aws_route53_record" "secret-management" {
  zone_id = aws_route53_zone.thoughtlyifyclick.zone_id
  name    = "secret-management.thoughtlyify.click"
  type    = "AAAA"
  alias {
    evaluate_target_health = true
    name                   = data.aws_lb.platform.dns_name
    zone_id                = data.aws_lb.platform.zone_id
  }
}
