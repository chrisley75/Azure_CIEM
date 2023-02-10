resource "azurerm_role_definition" "resourceManagementPrivateLinks_write_role" {
  name        = "CIEM resourceManagementPrivateLinks_write_role"
  scope       = data.azurerm_subscription.current.id
  description = "CIEM resourceManagementPrivateLinks_write_role created via Terraform"
  permissions {
    actions = ["Microsoft.Authorization/policyAssignments/resourceManagementPrivateLinks/write"]
    not_actions = []
  }
  timeouts {
    create = "5m"
    read = "5m"
  }
}
resource "azuread_user" "users_resourceManagementPrivateLinks_write" {
  user_principal_name = format(
    "%s@%s",
    "ciem-resourceManagementPrivateLinks_write",
    local.domain_name
  )
  password = "CIEMP@sswd991212!"
  force_password_change = true
  display_name = "CIEM User resourceManagementPrivateLinks_write"
}
resource "azurerm_role_assignment" "resourceManagementPrivateLinks_write_role" {
  scope       = data.azurerm_subscription.current.id
  principal_id = azuread_user.users_resourceManagementPrivateLinks_write.object_id
  role_definition_id = azurerm_role_definition.resourceManagementPrivateLinks_write_role.role_definition_resource_id
}
