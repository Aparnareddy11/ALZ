


data "azapi_client_config" "current" {}

# module "avm_ptn_alz_default" {
#   source             = "Azure/avm-ptn-alz/azurerm"
#   version            = "0.19.0"
#   architecture_name  = "alz"
#   location           = "eastus"
#   parent_resource_id = data.azapi_client_config.current.tenant_id
#   enable_telemetry   = true

#   retries = {
#     management_groups = {
#       error_message_regex = [
#         "AuthorizationFailed",
#         "context deadline exceeded",
#         "Permission to Microsoft.Management/managementGroups"
#       ]
#       interval_seconds     = 10
#       max_interval_seconds = 60
#     }
#   }

#   timeouts = {
#     management_group = {
#       create = "120m"
#       read   = "120m"
#     }
#   }
# }

module "avm-ptn-alz-connectivity-hub-and-spoke-vnet" {
  source  = "Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm"
  version = "0.16.11"
}
