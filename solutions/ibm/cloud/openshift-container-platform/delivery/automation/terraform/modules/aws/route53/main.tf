#------------------------------------------------------------------------------
# AWS Route53 Module for OpenShift
#------------------------------------------------------------------------------
# Creates DNS records for cluster API and application ingress
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Hosted Zone (create or use existing)
#------------------------------------------------------------------------------
data "aws_route53_zone" "selected" {
  count = var.create_hosted_zone ? 0 : 1

  name         = "${var.base_domain}."
  private_zone = var.private_zone
}

resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0

  name = var.base_domain

  dynamic "vpc" {
    for_each = var.private_zone ? [var.vpc_id] : []
    content {
      vpc_id = vpc.value
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}.${var.base_domain}"
  })
}

locals {
  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.selected[0].zone_id
}

#------------------------------------------------------------------------------
# API Server DNS Record
#------------------------------------------------------------------------------
resource "aws_route53_record" "api" {
  zone_id = local.zone_id
  name    = "api.${var.cluster_name}.${var.base_domain}"
  type    = "A"

  alias {
    name                   = var.api_lb_dns_name
    zone_id                = var.api_lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api_int" {
  zone_id = local.zone_id
  name    = "api-int.${var.cluster_name}.${var.base_domain}"
  type    = "A"

  alias {
    name                   = var.api_lb_dns_name
    zone_id                = var.api_lb_zone_id
    evaluate_target_health = true
  }
}

#------------------------------------------------------------------------------
# Application Ingress Wildcard DNS Record
#------------------------------------------------------------------------------
resource "aws_route53_record" "apps_wildcard" {
  count = var.ingress_lb_dns_name != null ? 1 : 0

  zone_id = local.zone_id
  name    = "*.apps.${var.cluster_name}.${var.base_domain}"
  type    = "A"

  alias {
    name                   = var.ingress_lb_dns_name
    zone_id                = var.ingress_lb_zone_id
    evaluate_target_health = true
  }
}

#------------------------------------------------------------------------------
# OAuth and Console DNS Records
#------------------------------------------------------------------------------
resource "aws_route53_record" "oauth" {
  count = var.ingress_lb_dns_name != null ? 1 : 0

  zone_id = local.zone_id
  name    = "oauth-openshift.apps.${var.cluster_name}.${var.base_domain}"
  type    = "A"

  alias {
    name                   = var.ingress_lb_dns_name
    zone_id                = var.ingress_lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "console" {
  count = var.ingress_lb_dns_name != null ? 1 : 0

  zone_id = local.zone_id
  name    = "console-openshift-console.apps.${var.cluster_name}.${var.base_domain}"
  type    = "A"

  alias {
    name                   = var.ingress_lb_dns_name
    zone_id                = var.ingress_lb_zone_id
    evaluate_target_health = true
  }
}
