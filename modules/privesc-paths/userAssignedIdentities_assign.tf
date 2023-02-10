resource "azurerm_role_definition" "userAssignedIdentities_assign_role" {
  name        = "CIEM userAssignedIdentities_assign_role"
  scope       = data.azurerm_subscription.current.id
  description = "CIEM userAssignedIdentities_assign_role created via Terraform"
  permissions {
    actions = ["Microsoft.ManagedIdentity/userAssignedIdentities/assign/action"]
    not_actions = []
  }
  timeouts {
    create = "5m"
    read = "5m"
  }
}
resource "azuread_user" "users_userAssignedIdentities_assign" {
  user_principal_name = format(
    "%s@%s",
    "ciem-userAssignedIdentities_assign",
    local.domain_name
  )
  password = "CIEMP@sswd991212!"
  force_password_change = true
  display_name = "CIEM User userAssignedIdentities_assign"
}
resource "azurerm_role_assignment" "userAssignedIdentities_assign_role" {
  scope       = data.azurerm_subscription.current.id
  principal_id = azuread_user.users_userAssignedIdentities_assign.object_id
  role_definition_id = azurerm_role_definition.userAssignedIdentities_assign_role.role_definition_resource_id
}
