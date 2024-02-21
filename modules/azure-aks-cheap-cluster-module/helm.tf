provider "helm" {

  kubernetes {
    host = (var.provision_aks == true ?
      azurerm_kubernetes_cluster.aks[0].kube_config[0].host :
      null
    )
    client_certificate = (var.provision_aks == true ?
      base64decode(azurerm_kubernetes_cluster.aks[0].kube_config[0].client_certificate) :
      null
    )
    client_key = (var.provision_aks == true ?
      base64decode(azurerm_kubernetes_cluster.aks[0].kube_config[0].client_key) :
      null
    )
    cluster_ca_certificate = (var.provision_aks == true ?
      base64decode(azurerm_kubernetes_cluster.aks[0].kube_config[0].cluster_ca_certificate) :
      null
    )
  }
}

# ingress-nginx will use dynamic IP - it is cheaper

resource "helm_release" "nginx_ingress" {
  count            = var.provision_aks == true ? 1 : 0
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  wait             = true
  timeout          = 200
  create_namespace = true

  dynamic "set" {
    for_each = var.nginx_ingress_additional_params
    content {
      name  = set.key
      value = set.value
    }
  }

}
