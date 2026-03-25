# ...existing code...

######################################################
# ARC on AKS (GitHub App authentication)
######################################################

# Read AKS created in main.tf (module.default)
data "azurerm_kubernetes_cluster" "aks" {
  name                = local.aks_name_automatic
  resource_group_name = azurerm_resource_group.this.name
  depends_on          = [module.automatic]
}

locals {
  # Some AKS setups do not expose kube_admin_config (for example when local admin access is restricted).
  aks_admin_kubeconfig = try(data.azurerm_kubernetes_cluster.aks.kube_admin_config[0], null)
  aks_user_kubeconfig  = try(data.azurerm_kubernetes_cluster.aks.kube_config[0], null)

  aks_kube_host = coalesce(
    try(local.aks_admin_kubeconfig.host, null),
    try(local.aks_user_kubeconfig.host, null)
  )

  aks_kube_client_certificate = coalesce(
    try(local.aks_admin_kubeconfig.client_certificate, null),
    try(local.aks_user_kubeconfig.client_certificate, null)
  )

  aks_kube_client_key = coalesce(
    try(local.aks_admin_kubeconfig.client_key, null),
    try(local.aks_user_kubeconfig.client_key, null)
  )

  aks_kube_cluster_ca_certificate = coalesce(
    try(local.aks_admin_kubeconfig.cluster_ca_certificate, null),
    try(local.aks_user_kubeconfig.cluster_ca_certificate, null)
  )
}

# Kubernetes provider against AKS admin kubeconfig
provider "kubernetes" {
  host                   = local.aks_kube_host
  client_certificate     = base64decode(local.aks_kube_client_certificate)
  client_key             = base64decode(local.aks_kube_client_key)
  cluster_ca_certificate = base64decode(local.aks_kube_cluster_ca_certificate)
}

# Helm provider against AKS admin kubeconfig
provider "helm" {
  kubernetes = {
    host                   = local.aks_kube_host
    client_certificate     = base64decode(local.aks_kube_client_certificate)
    client_key             = base64decode(local.aks_kube_client_key)
    cluster_ca_certificate = base64decode(local.aks_kube_cluster_ca_certificate)
  }
}

# Namespaces
resource "kubernetes_namespace" "arc_system" {
  metadata {
    name = "arc-system"
  }
}

resource "kubernetes_namespace" "arc_runners" {
  metadata {
    name = "arc-runners"
  }
}

# GitHub App secret for ARC
resource "kubernetes_secret" "arc_github_secret" {
  metadata {
    name      = "arc-github-secret"
    namespace = kubernetes_namespace.arc_runners.metadata[0].name
  }

  data = {
    github_app_id              = var.github_app_id
    github_app_installation_id = var.github_app_installation_id
    github_app_private_key     = var.github_app_private_key
  }

  type = "Opaque"
}

# ARC controller chart
resource "helm_release" "arc_controller" {
  name             = "arc"
  namespace        = kubernetes_namespace.arc_system.metadata[0].name
  create_namespace = false

  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set-controller"
  version    = var.arc_controller_chart_version

  depends_on = [kubernetes_namespace.arc_system]
}

# ARC runner scale set chart
resource "helm_release" "arc_runner_scale_set" {
  name             = var.arc_runner_scale_set_name
  namespace        = kubernetes_namespace.arc_runners.metadata[0].name
  create_namespace = false

  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set"
  version    = var.arc_runner_chart_version

  values = [
    yamlencode({
      githubConfigUrl    = var.github_config_url
      githubConfigSecret = "arc-github-secret"

      runnerScaleSetName = var.arc_runner_scale_set_name
      minRunners         = var.arc_min_runners
      maxRunners         = var.arc_max_runners

      controllerServiceAccount = {
        namespace = kubernetes_namespace.arc_system.metadata[0].name
        name      = "gha-runner-scale-set-controller"
      }

      template = {
        spec = {
          containers = [
            {
              name  = "runner"
              image = "ghcr.io/actions/actions-runner:latest"
            }
          ]
        }
      }
    })
  ]

  depends_on = [
    helm_release.arc_controller,
    kubernetes_secret.arc_github_secret
  ]
}

######################################################
# Variables
######################################################

variable "github_config_url" {
  description = "GitHub org/repo URL. Example: https://github.com/<org> or https://github.com/<org>/<repo>"
  type        = string
}

variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID"
  type        = string
}

variable "github_app_private_key" {
  description = "GitHub App private key in PEM format"
  type        = string
  sensitive   = true
}

variable "arc_runner_scale_set_name" {
  description = "ARC runner scale set name"
  type        = string
  default     = "aks-arc-runners"
}

variable "arc_min_runners" {
  description = "Minimum number of runners"
  type        = number
  default     = 1
}

variable "arc_max_runners" {
  description = "Maximum number of runners"
  type        = number
  default     = 10
}

variable "arc_controller_chart_version" {
  description = "ARC controller Helm chart version"
  type        = string
  default     = "0.11.0"
}

variable "arc_runner_chart_version" {
  description = "ARC runner scale set Helm chart version"
  type        = string
  default     = "0.11.0"
}

######################################################
# Outputs
######################################################

output "arc_namespaces" {
  value = {
    system  = kubernetes_namespace.arc_system.metadata[0].name
    runners = kubernetes_namespace.arc_runners.metadata[0].name
  }
}

output "arc_runner_scale_set" {
  value = {
    name      = helm_release.arc_runner_scale_set.name
    namespace = helm_release.arc_runner_scale_set.namespace
  }
}
