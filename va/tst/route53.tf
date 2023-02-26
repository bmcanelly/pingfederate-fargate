
resource aws_route53_record external {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "${local.env}.${local.dns_zone}"
  type    = "A"

  alias {
    name    = aws_lb.this.dns_name
    zone_id = aws_lb.this.zone_id

    evaluate_target_health = false
  }
}
