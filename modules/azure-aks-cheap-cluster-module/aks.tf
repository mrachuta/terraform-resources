resource "azurerm_kubernetes_cluster" "aks" {
  count               = var.provision_aks == true ? 1 : 0
  name                = var.aks_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location = (var.aks_custom_region != null ?
    var.aks_custom_region :
    data.azurerm_resource_group.rg.location
  )
  dns_prefix          = var.aks_name
  sku_tier            = "Free"
  node_resource_group = var.aks_resources_rg_name

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = var.aks_lb_sku
  }

  dynamic "api_server_access_profile" {
    for_each = (
      var.aks_lb_sku == "standard" && var.aks_auth_ip_ranges != null
    ) ? [1] : []
    content {
      authorized_ip_ranges = [
        var.aks_auth_ip_ranges
      ]
    }
  }

  default_node_pool {
    name                        = "default"
    node_count                  = var.aks_node_count
    vm_size                     = var.aks_node_sku
    os_disk_size_gb             = 32
    os_disk_type                = "Managed"
    enable_auto_scaling         = false
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(
    {
      "managed_by" = "terraform"
    },
    var.extra_tags
  )
}

resource "azurerm_kubernetes_cluster_node_pool" "aks_spot_pool" {
  count                 = var.aks_enable_spot_nodepool == true ? 1 : 0
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks[0].id
  vm_size               = var.aks_spot_node_sku
  node_count            = var.aks_spot_node_count
  enable_auto_scaling   = false
  priority              = "Spot"

  tags = merge(
    {
      "managed_by" = "terraform"
    },
    var.extra_tags
  )
}

# Get loadbalancer
data "azurerm_lb" "aks_loadbalancer" {
  count               = var.aks_scaling_details_default_node.enabled == true ? 1 : 0
  name                = "kubernetes"
  resource_group_name = var.aks_resources_rg_name
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

# Get backend pool attached to loadbalancer
data "azurerm_lb_backend_address_pool" "aks_loadbalancer_backend" {
  count           = var.aks_scaling_details_default_node.enabled == true ? 1 : 0
  name            = "kubernetes"
  loadbalancer_id = data.azurerm_lb.aks_loadbalancer[0].id
}

resource "azurerm_monitor_autoscale_setting" "aks_default_node_autoscaler" {
  count               = var.aks_scaling_details_default_node.enabled == true ? 1 : 0
  name                = "${var.aks_name}DefaultAutoscaler"
  resource_group_name = azurerm_kubernetes_cluster.aks[0].node_resource_group
  location            = azurerm_kubernetes_cluster.aks[0].location
  # Get VMSS id basing on backend address pools
  target_resource_id = split(
    "/virtualMachines/",
    data.azurerm_lb_backend_address_pool.aks_loadbalancer_backend[0].backend_ip_configurations[0].id
  )[0]

  profile {
    name = "inactiveProfile"

    capacity {
      default = 0
      minimum = 0
      maximum = 0
    }

    recurrence {
      timezone = var.aks_scaling_details_default_node.timezone
      days     = var.aks_scaling_details_default_node.days
      hours    = [var.aks_scaling_details_default_node.stop_time_HH]
      minutes  = [var.aks_scaling_details_default_node.stop_time_MM]
    }
  }

  profile {
    name = "activeProfile"

    capacity {
      default = var.aks_node_count
      minimum = var.aks_node_count
      maximum = var.aks_node_count
    }

    recurrence {
      timezone = var.aks_scaling_details_default_node.timezone
      days     = var.aks_scaling_details_default_node.days
      hours    = [var.aks_scaling_details_default_node.start_time_HH]
      minutes  = [var.aks_scaling_details_default_node.start_time_MM]
    }
  }
}
