
data "azapi_client_config" "current" {}

module "avm-ptn-alz-connectivity-hub-and-spoke-vnet" {
  source  = "Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm"
  version = "0.16.11"
}


module "avm-ptn-alz-connectivity-hub-and-spoke-vnet_example_basic-options-and-single-region" {
  source  = "Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm//examples/basic-options-and-single-region"
  version = "0.16.11"
}


# # module "avm-ptn-alz-connectivity-hub-and-spoke-vnet_example_full-multi-region" {
# #   source  = "Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm//examples/full-multi-region"
# #   version = "0.16.11"
# }
