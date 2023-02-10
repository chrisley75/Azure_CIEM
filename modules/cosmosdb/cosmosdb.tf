data "azurerm_subscription" "current" {
}
variable "resource_group_name_prefix" {
  default     = "CIEMrg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = "eastus"
  name     = random_pet.rg_name.id
}
resource "azurerm_user_assigned_identity" "identity" {
  location            = "eastus"
  name                = "CIEM-UserAssigned-Identity"
  resource_group_name = azurerm_resource_group.rg.name
}
variable "custom_keyvault_permissions" {
type = list(string)
    default = [
          "Microsoft.KeyVault/vaults/read",
          "Microsoft.KeyVault/vaults/write",
          "Microsoft.KeyVault/vaults/deploy/action",
          "Microsoft.KeyVault/vaults/accessPolicies/write",
        ]
}
resource "azurerm_role_definition" "custom_keyvault_permissions" {
  name        = "CIEM custom_keyvault_permissions role for cosmosDB"
  scope       = data.azurerm_subscription.current.id
  description = "CIEM custom_keyvault_permissions for cosmosDB created via Terraform"
  permissions {
    actions = var.custom_keyvault_permissions
    not_actions = []
  }
  timeouts {
    create = "5m"
    read = "5m"
  }
}
resource "azurerm_role_assignment" "UserAssigned_keyvault" {
  scope                = data.azurerm_subscription.current.id
  role_definition_id = azurerm_role_definition.custom_keyvault_permissions.role_definition_resource_id
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}
resource "azurerm_cosmosdb_account" "CIEM" {
  name                      = "ciem-cosmosdb"
  location                  = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = false
  geo_location {
    location          = "eastus"
    failover_priority = 0
  }
  consistency_policy {
    consistency_level       = "Session"
  }
  public_network_access_enabled = false
  enable_free_tier = true
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }
}

resource "azurerm_cosmosdb_sql_database" "CIEM" {
  name                = "ciem-sqldb"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.CIEM.name
}

resource "azurerm_cosmosdb_sql_container" "CIEM" {
  name                  = "ciemsql-container"
  resource_group_name = azurerm_resource_group.rg.name
  account_name          = azurerm_cosmosdb_account.CIEM.name
  database_name         = azurerm_cosmosdb_sql_database.CIEM.name
  partition_key_path    = "/definition/id"
  partition_key_version = 1
  }
