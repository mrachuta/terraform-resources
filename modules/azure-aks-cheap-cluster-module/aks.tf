resource "azurerm_kubernetes_cluster" "aks" {
  count = var.provision_aks == true ? 1 : 0

  name                = var.aks_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = (var.aks_custom_region != null ?
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
    name                 = "default"
    node_count           = var.aks_node_count
    vm_size              = var.aks_node_sku
    os_disk_size_gb      = 32
    os_disk_type         = "Managed"
    auto_scaling_enabled = false

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }

    tags = merge(
      {
        "managed_by"        = "terraform"
        "module-name"       = "azure-aks-cheap-cluster"
        "default-node-pool" = "true"
      },
      var.extra_tags
    )
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(
    {
      "managed_by"  = "terraform"
      "module-name" = "azure-aks-cheap-cluster"
    },
    var.extra_tags
  )
}

resource "azurerm_kubernetes_cluster_node_pool" "aks_spot_pool" {
  count = var.aks_enable_spot_nodepool == true ? 1 : 0

  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks[0].id
  vm_size               = var.aks_spot_node_sku
  node_count            = var.aks_spot_node_count
  auto_scaling_enabled  = false
  priority              = "Spot"

  tags = merge(
    {
      "managed_by"  = "terraform"
      "module-name" = "azure-aks-cheap-cluster"
    },
    var.extra_tags
  )
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  count = var.provision_aks == true ? 1 : 0

  name                = "${var.contapp_env_name}-aks-config-uai"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = (var.aks_custom_region != null ?
    var.aks_custom_region :
    data.azurerm_resource_group.rg.location
  )

}

resource "azurerm_role_assignment" "role_aks_rbac_cluster_admin" {
  count = var.provision_aks == true ? 1 : 0

  scope                = azurerm_kubernetes_cluster.aks[0].id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = azurerm_user_assigned_identity.managed_identity[0].principal_id
}

resource "azurerm_role_assignment" "role_aks_cluster_admin" {
  count = var.provision_aks == true ? 1 : 0

  scope                = azurerm_kubernetes_cluster.aks[0].id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azurerm_user_assigned_identity.managed_identity[0].principal_id
}

resource "azurerm_container_app_environment" "container_app_environment" {
  count = var.provision_aks == true ? 1 : 0

  name                = var.contapp_env_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = (var.aks_custom_region != null ?
    var.aks_custom_region :
    data.azurerm_resource_group.rg.location
  )

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    maximum_count         = 1
    minimum_count         = 0
  }

  # Seems to be provider issue. Block workload_profile have to be declared
  # name and workload_profile_type arguments have to be strictly defined
  # Even with these, terraform is always trying to re-define it from null to specified values.
  lifecycle {
    ignore_changes = [workload_profile]
  }
}

resource "azurerm_container_app_job" "aks_config_job" {
  count = var.provision_aks == true ? 1 : 0

  name                         = "${var.contapp_env_name}-aks-config-job"
  resource_group_name          = data.azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.container_app_environment[0].id
  location                     = (var.aks_custom_region != null ?
    var.aks_custom_region :
    data.azurerm_resource_group.rg.location
  )

  replica_timeout_in_seconds = 300
  replica_retry_limit        = 1
  workload_profile_name      = "Consumption"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managed_identity[0].id]
  }

  manual_trigger_config {
  }

  template {
    container {
      image   = "mcr.microsoft.com/azure-cli:latest"
      name    = "container01"
      cpu     = 0.25
      memory  = "0.5Gi"
      command = ["/bin/bash"]
      args    = [
        "-c",
        join("", [
          "curl -LO https://dl.k8s.io/release/$${KUBECTL_VER}/bin/linux/amd64/kubectl && ",
          "mv kubectl /usr/local/bin/kubectl && ",
          "chmod +x /usr/local/bin/kubectl && ",
          "tdnf install helm -y && ",
          "az login --identity --client-id $UAI_ID && ",
          "az aks get-credentials --resource-group $RG_NAME ",
          "--name $CLUSTER_NAME --admin --overwrite-existing && ",
          "helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && ",
          "helm repo update && ",
          "helm upgrade --install --create-namespace --namespace ingress-nginx ",
          "ingress-nginx ingress-nginx/ingress-nginx $INGRESS_PARAMS"
        ])
      ]
      # GH issue: https://github.com/Azure/azure-cli/issues/22677
      env {
        name  = "APPSETTING_WEBSITE_SITE_NAME"
        value = "DUMMY"
      }
      env {
        name  = "KUBE_VER"
        value = "1.31.0"
      }
      env {
        name  = "RG_NAME"
        value = data.azurerm_resource_group.rg.name
      }
      env {
        name  = "UAI_ID"
        value = azurerm_user_assigned_identity.managed_identity[0].client_id
      }
      env {
        name  = "CLUSTER_NAME"
        value = var.aks_name
      }
      env {
        name  = "INGRESS_PARAMS"
        value = length(var.nginx_ingress_additional_params) > 0 ? join(" ", [
          for k, v in var.nginx_ingress_additional_params : "--set-string ${k}=${v}"
        ]) : ""
      }
    }
  }

}

# local-exec provider is used to allow to handle everything (AKS provisioning and configuration)
# within a single module. When helm provider was used, there was a problem with destroy 
# (chicken-and-egg problem; it was required to use terraform destroy -target first).
resource "null_resource" "run_aks_config_job" {
  count = var.provision_aks == true ? 1 : 0

  provisioner "local-exec" {
    environment = {
      "ARM_CLIENT_ID"       = data.azurerm_client_config.current.client_id
      "ARM_CLIENT_SECRET"   = "${var.provisioner_arm_client_secret}"
      "ARM_TENANT_ID"       = data.azurerm_client_config.current.tenant_id
      "ARM_SUBSCRIPTION_ID" = data.azurerm_client_config.current.subscription_id
    }
    command = <<EOF
${var.az_cli_path} login --service-principal \
--username $ARM_CLIENT_ID \
--password $ARM_CLIENT_SECRET \
--tenant $ARM_TENANT_ID \
-o tsv
${var.az_cli_path} account set --subscription $ARM_SUBSCRIPTION_ID \
-o tsv
${var.az_cli_path} containerapp job start \
-n ${var.contapp_env_name}-aks-config-job \
-g ${data.azurerm_resource_group.rg.name} \
-o tsv
echo 'Sleeping for 30 seconds to avoid reaching Azure API request limit...'
sleep 30
for i in {1..10}; do
    output=$(${var.az_cli_path} containerapp job execution list \
    -n ${var.contapp_env_name}-aks-config-job \
    -g ${data.azurerm_resource_group.rg.name} \
    --query '[0].properties.status' -o tsv)
    echo "Current output: $output"
    if [ "$output" == "Succeeded" ]; then
        echo "Command succeeded on attempt $i!"
        exit 0
    fi
    echo "Attempt $i failed. Sleeping for $((i * 3)) seconds..."
    sleep $((i * 4))
done

echo "Command returned $output after 10 retries. Exiting..."
exit 1
EOF
  }

  depends_on = [
    azurerm_container_app_job.aks_config_job,
    azurerm_kubernetes_cluster.aks,
    azurerm_role_assignment.role_aks_cluster_admin,
    azurerm_role_assignment.role_aks_rbac_cluster_admin
  ]

  lifecycle {
    replace_triggered_by = [azurerm_container_app_job.aks_config_job[0]]
  }
}

# Get loadbalancer
data "azurerm_lb" "aks_loadbalancer" {
  count = var.provision_aks == true ? 1 : 0

  name                = "kubernetes"
  resource_group_name = var.aks_resources_rg_name

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    null_resource.run_aks_config_job
  ]
}

# Get loadbalancer external IP address
data "azurerm_public_ip" "aks_loadbalancer_ip" {
  count = var.provision_aks == true ? 1 : 0

  name                = basename(data.azurerm_lb.aks_loadbalancer[0].frontend_ip_configuration[0].public_ip_address_id)
  resource_group_name = var.aks_resources_rg_name
}

# Get default's nodepool vmss
data "azurerm_resources" "aks_default_nodepool" {
  resource_group_name = var.aks_resources_rg_name
  type                = "Microsoft.Compute/virtualMachineScaleSets"

  required_tags = merge(
    {
      "managed_by"        = "terraform"
      "module-name"       = "azure-aks-cheap-cluster"
      "default-node-pool" = "true"
    },
    var.extra_tags
  )

  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "azurerm_monitor_autoscale_setting" "aks_default_node_autoscaler" {
  count = (
    var.provision_aks == true &&
    var.aks_scaling_details_default_node != null
  ) ? 1 : 0

  name                = "${var.aks_name}DefaultAutoscaler"
  resource_group_name = azurerm_kubernetes_cluster.aks[0].node_resource_group
  location            = azurerm_kubernetes_cluster.aks[0].location

  tags = merge(
    {
      "managed_by"  = "terraform"
      "module-name" = "azure-aks-cheap-cluster"
    },
    var.extra_tags
  )

  target_resource_id = data.azurerm_resources.aks_default_nodepool.resources[0].id

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

  depends_on = [azurerm_kubernetes_cluster.aks]
}
