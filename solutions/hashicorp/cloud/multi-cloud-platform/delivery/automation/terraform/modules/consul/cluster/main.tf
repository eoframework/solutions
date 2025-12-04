#------------------------------------------------------------------------------
# HashiCorp Consul Cluster Module
#------------------------------------------------------------------------------
# Deploys Consul on EKS using Helm chart
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Consul Helm Release
#------------------------------------------------------------------------------
resource "helm_release" "consul" {
  name       = "consul"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.consul.helm_chart_version
  namespace  = var.consul.namespace

  create_namespace = true

  values = [
    yamlencode({
      global = {
        name       = "${var.name_prefix}-consul"
        datacenter = var.consul.datacenter
        tls = {
          enabled           = true
          enableAutoEncrypt = true
        }
        acls = {
          manageSystemACLs = var.consul.enable_acls
        }
        gossipEncryption = {
          autoGenerate = true
        }
      }
      server = {
        replicas = var.consul.server_replicas
        storage  = "${var.consul.server_storage_size}Gi"
        resources = {
          requests = {
            memory = var.consul.server_memory_request
            cpu    = var.consul.server_cpu_request
          }
          limits = {
            memory = var.consul.server_memory_limit
            cpu    = var.consul.server_cpu_limit
          }
        }
      }
      client = {
        enabled = true
      }
      connectInject = {
        enabled = var.consul.enable_connect_inject
        default = var.consul.connect_inject_default
      }
      controller = {
        enabled = var.consul.enable_controller
      }
      ui = {
        enabled = var.consul.enable_ui
        service = {
          type = "ClusterIP"
        }
      }
      prometheus = {
        enabled = var.consul.enable_metrics
      }
    })
  ]

  set_sensitive {
    name  = "global.acls.bootstrapToken.secretName"
    value = var.consul.enable_acls ? kubernetes_secret.consul_bootstrap[0].metadata[0].name : ""
  }
}

#------------------------------------------------------------------------------
# Kubernetes Resources
#------------------------------------------------------------------------------
resource "kubernetes_namespace" "consul" {
  count = var.consul.create_namespace ? 1 : 0

  metadata {
    name = var.consul.namespace
    labels = {
      name        = var.consul.namespace
      environment = var.common_tags["Environment"]
    }
  }
}

resource "kubernetes_secret" "consul_bootstrap" {
  count = var.consul.enable_acls ? 1 : 0

  metadata {
    name      = "consul-bootstrap-token"
    namespace = var.consul.namespace
  }

  data = {
    token = var.consul.bootstrap_token
  }

  depends_on = [kubernetes_namespace.consul]
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------
data "aws_eks_cluster" "target" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "target" {
  name = var.eks_cluster_name
}
