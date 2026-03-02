terraform {
  required_version = "~> 1.10.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace_v1" "certificates" {
  metadata {
    name = "certificates"
  }
}

resource "kubernetes_secret_v1" "certificates_cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = kubernetes_namespace_v1.certificates.metadata[0].name
  }
  data = {
    "api-token" = var.cloudflare_api_token
  }
}

resource "kubernetes_manifest" "letsencrypt_staging" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging"
    }
    spec = {
      acme = {
        email = var.email
        privateKeySecretRef = {
          name = "letsencrypt-staging"
        }
        profile       = "tlsserver"
        server        = "https://acme-staging-v02.api.letsencrypt.org/directory"
        skipTLSVerify = false
        solvers = [{
          dns01 = {
            cloudflare = {
              apiTokenSecretRef = {
                key  = "api-token"
                name = "cloudflare-api-token"
              }
            }
          }
        }]
      }
    }
  }
}

resource "helm_release" "cert-manager" {
  chart      = "cert-manager"
  name       = "cert-manager"
  namespace  = kubernetes_namespace_v1.certificates.metadata[0].name
  repository = "oci://quay.io/jetstack/charts"
  version    = "1.19.1"
  values = [
    file("${path.module}/values/cert-manager.yaml")
  ]
}
