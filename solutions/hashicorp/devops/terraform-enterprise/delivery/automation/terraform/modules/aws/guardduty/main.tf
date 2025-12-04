#------------------------------------------------------------------------------
# AWS GuardDuty Module (Provider-Level Primitive)
#------------------------------------------------------------------------------
# Reusable GuardDuty detector configuration
#------------------------------------------------------------------------------

resource "aws_guardduty_detector" "main" {
  enable = var.enabled

  datasources {
    s3_logs {
      enable = var.enable_s3_logs
    }
    kubernetes {
      audit_logs {
        enable = var.enable_kubernetes_audit_logs
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.enable_malware_protection
        }
      }
    }
  }

  finding_publishing_frequency = var.finding_publishing_frequency

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-guardduty"
  })
}
