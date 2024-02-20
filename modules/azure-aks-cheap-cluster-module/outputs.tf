output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}

output "acr_address" {
  value = var.provision_acr == true ? azurerm_container_registry.acr[0].login_server : null
}

output "aks_cluster_name" {
  value = var.provision_aks == true ? azurerm_kubernetes_cluster.aks[0].name : null
}
