# Retrieve domain information
/*
Azure Active Directory (AD) B2C is a highly available and global identity management service for your customer-facing applications, that easily integrates across mobile and web platforms and scales to hundreds of millions of identities. 
Enable your customers and consumers to log on to your applications through fully customizable experiences, whether they use an existing social account or create new credentials. With Azure AD B2C, you can:

    Protect your customers' identities
    Enable login with social media identities
    Customize user experiences
    Pay only for what you use on a per-Monthly Active User (MAU) basis
*/
data "azuread_domains" "default" {
  only_initial = true
}
data "azurerm_subscription" "current" {
}

locals {
  domain_name = data.azuread_domains.default.domains.0.domain_name
}

resource "azurerm_role_definition" "b2cwrite_role" {
  name        = "CIEM b2cwrite_role"
  scope       = data.azurerm_subscription.current.id
  description = "CIEM b2cwrite_role created via Terraform"
  permissions {
    actions = ["Microsoft.AzureActiveDirectory/b2cDirectories/write",
               "Microsoft.Resources/subscriptions/resourceGroups/write"]
    not_actions = []
  }
  timeouts {
    create = "5m"
    read = "5m"
  }
}
resource "azuread_user" "users_b2cwrite" {
  user_principal_name = format(
    "%s@%s",
    "ciem-user-b2cwrite",
    local.domain_name
  )
  password = "CIEMP@sswd991212!"
  force_password_change = true
  display_name = "CIEM User b2cwrite"
}
resource "azurerm_role_assignment" "b2cwrite_role" {
  scope       = data.azurerm_subscription.current.id
  principal_id = azuread_user.users_b2cwrite.object_id
  role_definition_id = azurerm_role_definition.b2cwrite_role.role_definition_resource_id
}
