# Initialize Helm (and install Tiller)
provider "helm" {

  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

# ingress-nginx will use dynamic IP - it is cheaper

# Add Kubernetes Stable Helm charts repo
resource "helm_repository" "ingress_nginx_repo" {
  name = "ingress-nginx"
  url  = "https://kubernetes.github.io/ingress-nginx"
}

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = helm_repository.ingress_nginx_repo.metadata.0.name
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"

  dynamic "set" {
    for_each = var.nginx_ingress_additional_params
    content {
      name  = nginx_ingress_additional_params.value.param_name
      value = nginx_ingress_additional_params.value.param_value
    }
  }

}
