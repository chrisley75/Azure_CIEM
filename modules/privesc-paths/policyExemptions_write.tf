resource "azurerm_role_definition" "policyExemptions_write_role" {
  name        = "CIEM policyExemptions_write_role"
  scope       = data.azurerm_subscription.current.id
  description = "CIEM policyExemptions_write_role created via Terraform"
  permissions {
    actions = ["Microsoft.Authorization/policyExemptions/write"]
    not_actions = []
  }
  timeouts {
    create = "5m"
    read = "5m"
  }
}
resource "azuread_user" "users_policyExemptions_write" {
  user_principal_name = format(
    "%s@%s",
    "ciem-policyExemptions_write",
    local.domain_name
  )
  password = "CIEMP@sswd991212!"
  force_password_change = true
  display_name = "CIEM User policyExemptions_write"
}
resource "azurerm_role_assignment" "policyExemptions_write_role" {
  scope       = data.azurerm_subscription.current.id
  principal_id = azuread_user.users_policyExemptions_write.object_id
  role_definition_id = azurerm_role_definition.policyExemptions_write_role.role_definition_resource_id
}
