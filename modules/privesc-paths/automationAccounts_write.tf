resource "azurerm_role_definition" "automationAccounts_write_role" {
  name        = "CIEM automationAccounts_write_role"
  scope       = data.azurerm_subscription.current.id
  description = "CIEM automationAccounts_write_role created via Terraform"
  permissions {
    actions = ["Microsoft.Automation/automationAccounts/*/write"]
    not_actions = []
  }
  timeouts {
    create = "5m"
    read = "5m"
  }
}
resource "azuread_user" "users_automationAccounts_write" {
  user_principal_name = format(
    "%s@%s",
    "ciem-automationAccounts_write",
    local.domain_name
  )
  password = "CIEMP@sswd991212!"
  force_password_change = true
  display_name = "CIEM User automationAccounts_write"
}
resource "azurerm_role_assignment" "automationAccounts_write_role" {
  scope       = data.azurerm_subscription.current.id
  principal_id = azuread_user.users_automationAccounts_write.object_id
  role_definition_id = azurerm_role_definition.automationAccounts_write_role.role_definition_resource_id
}
