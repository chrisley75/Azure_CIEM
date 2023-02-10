resource "azurerm_role_definition" "keyvault_deployaction_role" {
  name        = "CIEM keyvault_deployaction_role"
  scope       = data.azurerm_subscription.current.id
  description = "CIEM keyvault_deployaction_role created via Terraform"
  permissions {
    actions = ["Microsoft.KeyVault/vaults/deploy/action"]
    not_actions = []
  }
  timeouts {
    create = "5m"
    read = "5m"
  }
}
resource "azuread_user" "users_keyvault_deployaction" {
  user_principal_name = format(
    "%s@%s",
    "ciem-keyvault_deployaction",
    local.domain_name
  )
  password = "CIEMP@sswd991212!"
  force_password_change = true
  display_name = "CIEM User keyvault_deployaction"
}
resource "azurerm_role_assignment" "keyvault_deployaction_role" {
  scope       = data.azurerm_subscription.current.id
  principal_id = azuread_user.users_keyvault_deployaction.object_id
  role_definition_id = azurerm_role_definition.keyvault_deployaction_role.role_definition_resource_id
}
