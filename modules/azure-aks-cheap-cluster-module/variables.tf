variable "existing_rg" {
  type        = string
  default     = "myexistingrg01"
  description = "Existing resoure group name; have to be created manually outside of terraform"
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to be added to each resource"
}

variable "provision_acr" {
  type        = bool
  default     = true
  description = "Set to true to provision Azure Container Registry"
}

# https://github.com/claranet/terraform-azurerm-regions/blob/master/REGIONS.md#azure-regions-mapping-list
variable "acr_custom_region" {
  type        = string
  default     = null
  description = "Define region to create ACR in; by default ACR will be created in the same region as RG"
}

variable "provision_aks" {
  type        = bool
  default     = true
  description = "Set to true to provision Azure Kubernetes Service (Cluster)"
}

variable "aks_custom_region" {
  type        = string
  default     = null
  description = "Define region to create AKS in; by default AKS will be created in the same region as RG"
}

variable "acr_name" {
  type        = string
  default     = "myacr01"
  description = "Name of Azure Container Registry"
}

variable "acr_grant_pull_role_to_aks" {
  type        = bool
  default     = false
  description = "Grant role over ACR to allow to pull images by AKS identity"
}

variable "aks_name" {
  type        = string
  default     = "myaks01"
  description = "Name of AKS cluster; will be used also as DNS prefix"
}

variable "aks_resources_rg_name" {
  type        = string
  default     = "myacr01_rg"
  description = "Name of resource group where AKS resources will be placed; will be created automatically"
}

variable "aks_lb_sku" {
  type        = string
  default     = "basic"
  description = "Type of loadbalancer for AKS; use 'standard' to restrict ranges to access Kubernetes (AKS) cluster API"
}

variable "aks_auth_ip_ranges" {
  type        = string
  default     = null
  description = "IP range to be able to access Kubernetes (AKS) cluster API"
}

variable "aks_node_count" {
  type        = number
  default     = 1
  description = "Node count for default nodepool"
}

variable "aks_node_sku" {
  type        = string
  default     = "Standard_B2s"
  description = "Machine SKU for default nodepool"
}

variable "aks_enable_spot_nodepool" {
  type        = bool
  default     = false
  description = "Provision nodepool with basing on cheap spot instance"
}

variable "aks_spot_node_sku" {
  type        = string
  default     = "Standard_B4ms"
  description = "Machine SKU for spot node pool"
}

variable "aks_spot_node_count" {
  type        = number
  default     = 1
  description = "Node count for spot node pool"
}

variable "nginx_ingress_additional_params" {
  type = map(string)
  default = {}
  description = "List of strings to declare additional ingress-nginx params"
}

variable "aks_scaling_details_default_node" {
  type = object({
    enabled       = bool
    days          = list(string)
    start_time_HH = number
    start_time_MM = number
    stop_time_HH  = number
    stop_time_MM  = number
    timezone      = string
  })
  default = {
    enabled       = true
    days          = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    start_time_HH = 08
    start_time_MM = 00
    stop_time_HH  = 20
    stop_time_MM  = 00
    timezone      = "UTC"
  }
  description = "An dict that enabling autoscaling on VMSS of default node pool to reduce costs"
}
