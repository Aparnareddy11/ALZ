# data "azapi_client_config" "current" {}

# # module "avm_ptn_alz_default" {
# #   source             = "Azure/avm-ptn-alz/azurerm"
# #   version            = "0.19.0"
# #   architecture_name  = "alz"
# #   location           = "eastus"
# #   parent_resource_id = data.azapi_client_config.current.tenant_id
# #   enable_telemetry   = true

# #   retries = {
# #     management_groups = {
# #       error_message_regex = [
# #         "AuthorizationFailed",
# #         "context deadline exceeded",
# #         "Permission to Microsoft.Management/managementGroups"
# #       ]
# #       interval_seconds     = 10
# #       max_interval_seconds = 60
# #     }
# #   }

# #   timeouts = {
# #     management_group = {
# #       create = "120m"
# #       read   = "120m"
# #     }
# #   }
# # }

# module "avm-ptn-alz-connectivity-hub-and-spoke-vnet" {
#   source  = "Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm"
#   version = "0.16.11"
# }


# module "avm-ptn-alz-connectivity-hub-and-spoke-vnet_example_basic-options-and-single-region" {
#   source  = "Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm//examples/basic-options-and-single-region"
#   version = "0.16.11"
# }


# module "avm-ptn-alz-connectivity-hub-and-spoke-vnet_example_full-multi-region" {
#   source  = "Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm//examples/full-multi-region"
#   version = "0.16.11"
# }



data "azurerm_client_config" "current" {}

# Ensure to select a region that meets criteria for AKS Automatic clusters.
# See this doc for more info: https://learn.microsoft.com/azure/aks/automatic/quick-automatic-managed-network?pivots=azure-portal#limitations
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.10.0"

  is_recommended = true
  region_filter  = ["swedencentral"]
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  location           = module.regions.regions[random_integer.region_index.result].name
  aks_name_base      = module.naming.kubernetes_cluster.name_unique
  aks_name_automatic = "${substr(local.aks_name_base, 0, 53)}-auto"
  aks_name_default   = "${substr(local.aks_name_base, 0, 53)}-base"

  # Network plan
  vnet_primary_cidr   = "10.100.0.0/16"
  vnet_secondary_cidr = "100.64.0.0/16"

  control_plane_subnets = {
    cp01 = "10.100.0.0/28"
    cp02 = "10.100.0.16/28"
  }

  data_plane_subnets = {
    dp01 = "10.100.1.0/26"
    dp02 = "10.100.1.64/26"
    dp03 = "10.100.1.128/26"
  }

  pod_secondary_subnets = {
    pod01 = "100.64.0.0/20"
    pod02 = "100.64.16.0/20"
    pod03 = "100.64.32.0/20"
  }
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = local.location
  name     = module.naming.resource_group.name_unique
}

# resource "azurerm_monitor_workspace" "this" {
#   location            = azurerm_resource_group.this.location
#   name                = "prom-${random_string.suffix.result}"
#   resource_group_name = azurerm_resource_group.this.name
# }

# resource "azurerm_virtual_network" "this" {
#   location            = azurerm_resource_group.this.location
#   name                = module.naming.virtual_network.name_unique
#   resource_group_name = azurerm_resource_group.this.name
#   address_space       = ["172.19.0.0/16"]
# }

resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [local.vnet_primary_cidr, local.vnet_secondary_cidr]
}

# 2 x /28 for AKS control plane
resource "azurerm_subnet" "control_plane" {
  for_each             = local.control_plane_subnets
  name                 = "snet-aks-${each.key}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]

  delegation {
    name = "aks-apiserver-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# 3 x /26 for AKS data plane
resource "azurerm_subnet" "data_plane" {
  for_each             = local.data_plane_subnets
  name                 = "snet-aks-${each.key}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}

# 3 x /20 non-routable secondary subnets for pod IP growth
resource "azurerm_subnet" "pod_secondary" {
  for_each             = local.pod_secondary_subnets
  name                 = "snet-aks-${each.key}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_role_assignment" "network_contributor_vnet" {
  scope                = azurerm_virtual_network.this.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

# resource "azurerm_role_assignment" "network_contributor" {
#   principal_id         = azurerm_user_assigned_identity.this.principal_id
#   scope                = azurerm_virtual_network.this.id
#   role_definition_name = "Network Contributor"
# }

# resource "azurerm_private_dns_zone" "this" {
#   name                = "privatelink.${azurerm_resource_group.this.location}.azmk8s.io"
#   resource_group_name = azurerm_resource_group.this.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "this" {
#   name                  = "privatelink-${azurerm_resource_group.this.location}-azmk8s-io"
#   private_dns_zone_name = azurerm_private_dns_zone.this.name
#   resource_group_name   = azurerm_resource_group.this.name
#   virtual_network_id    = azurerm_virtual_network.this.idGitHub App-based secret version
# }

# resource "azurerm_role_assignment" "private_dns_zone_contributor" {
#   principal_id         = azurerm_user_assigned_identity.this.principal_id
#   scope                = azurerm_private_dns_zone.this.id
#   role_definition_name = "Private DNS Zone Contributor"
# }

# resource "azurerm_log_analytics_workspace" "this" {
#   location            = azurerm_resource_group.this.location
#   name                = module.naming.log_analytics_workspace.name_unique
#   resource_group_name = azurerm_resource_group.this.name
#   retention_in_days   = 30
#   sku                 = "PerGB2018"
# }

# module "automatic" {
#   source    = "Azure/avm-res-containerservice-managedcluster/azurerm"
#   version   = "0.5.2"
#   parent_id = azurerm_resource_group.this.id

#   name     = local.aks_name_automatic
#   location = azurerm_resource_group.this.location

# }


module "default" {
  source    = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version   = "0.5.3"
  location  = azurerm_resource_group.this.location
  name      = local.aks_name_default
  parent_id = azurerm_resource_group.this.id

  aad_profile = {
    enable_azure_rbac      = true
    tenant_id              = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids = []
    managed                = true
  }

  api_server_access_profile = {
    enable_private_cluster = true
    subnet_id              = azurerm_subnet.control_plane["cp01"].id
  }

  auto_upgrade_profile = {
    upgrade_channel = "none"
  }

  default_agent_pool = {
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.data_plane["dp01"].id
    pod_subnet_id  = azurerm_subnet.pod_secondary["pod01"].id

    upgrade_settings = {
      max_surge = "10%"
    }
  }

  dns_prefix = "defaultexample"

  managed_identities = {
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this.id]
  }

  sku = {
    tier = "Standard"
    name = "Base"
  }

  depends_on = [azurerm_role_assignment.network_contributor_vnet]
}
