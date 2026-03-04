


data "azapi_client_config" "current" {}

module "avm_ptn_alz_default" {
  source             = "Azure/avm-ptn-alz/azurerm/examples/default"
  architecture_name  = "alz"
  location           = "eastus"
  parent_resource_id = data.azapi_client_config.current.tenant_id
  enable_telemetry   = var.enable_telemetry
}
