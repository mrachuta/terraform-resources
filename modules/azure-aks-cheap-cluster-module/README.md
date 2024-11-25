# General info

Terraform module for creating Azure Container Registry, Azure Kubernertes Service and additional helper objects. Main features are: 
* automatic deployment of ingress and external load balancer
* scaling that you can add to VMSS to turn them off completely for a night (for example).
The idea behind this module is to bring as cheapest as possible kubernetes stack in cloud.
Personally I am using region Central India and Standard_B4as_v2 VM (1 machine) because of best price/capacity ratio.

# Requirements

No special requirements.

# Usage

See *variables.tf* file for required / optional variables
