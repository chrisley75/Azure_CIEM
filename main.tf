provider "azuread" {
}
provider "azurerm" {
  features {}
}
# Retrieve domain information
data "azuread_domains" "default" {
  only_initial = true
}
data "azurerm_subscription" "current" {
}

locals {
  domain_name = data.azuread_domains.default.domains.0.domain_name
}

#######################################################
# Azure AD applications
#######################################################
resource "azuread_application" "serviceprinciple_owner" {
  display_name            = "Example App for CIEM testing 1 - Owner Role"
}
resource "azuread_application" "serviceprinciple_contrbutor" {
  display_name            = "Example App for CIEM testing 2 - Contributor Role"
}
resource "azuread_application" "serviceprinciple_reader" {
  display_name            = "Example App for CIEM testing 3 - Reader Role"
}
resource "azuread_application" "serviceprinciple_keyvault" {
  display_name            = "Example App for CIEM testing 4 - Key Vault Role"
}
resource "azuread_application" "serviceprinciple_ownerdenyall" {
  display_name            = "Example App for CIEM testing 5 - Owner + Denyall Role"
}
#######################################################
# Azure AD service principles
#######################################################
resource "azuread_service_principal" "serviceprinciple_owner" {
  application_id = azuread_application.serviceprinciple_owner.application_id
  tags = ["CIEM_Owner"]
}
resource "azuread_service_principal" "serviceprinciple_contrbutor" {
  application_id = azuread_application.serviceprinciple_contrbutor.application_id
  tags = ["CIEM_Contrbutor"]
}
resource "azuread_service_principal" "serviceprinciple_reader" {
  application_id = azuread_application.serviceprinciple_reader.application_id
  tags = ["CIEM_Reader"]
}
resource "azuread_service_principal" "serviceprinciple_keyvault" {
  application_id = azuread_application.serviceprinciple_keyvault.application_id
  tags = ["CIEM_Key Vault"]
}
resource "azuread_service_principal" "serviceprinciple_ownerdenyall" {
  application_id = azuread_application.serviceprinciple_ownerdenyall.application_id
  tags = ["CIEM_Key owner + denyall"]
}
#######################################################
# Azure AD groups
#######################################################
data "azuread_user" "CIEM1" {
  user_principal_name = format("%s@%s", "pparker", local.domain_name)
}
resource "azuread_group" "CIEM1" {
  display_name = "CIEM1"
  security_enabled = true
  }
resource "azuread_group_member" "CIEM1" {
  group_object_id = azuread_group.CIEM1.id
  member_object_id = data.azuread_user.CIEM1.object_id
}
data "azuread_user" "CIEM2" {
  user_principal_name = format("%s@%s", "skyle", local.domain_name)
}
resource "azuread_group" "CIEM2" {
  display_name = "CIEM2"
  security_enabled = true
  }
resource "azuread_group_member" "CIEM2" {
  group_object_id = azuread_group.CIEM2.id
  member_object_id = data.azuread_user.CIEM2.object_id
}
data "azuread_user" "CIEM3" {
  user_principal_name = format("%s@%s", "srogers", local.domain_name)
}
resource "azuread_group" "CIEM3" {
  display_name = "CIEM3"
  security_enabled = true
  }
resource "azuread_group_member" "CIEM3" {
  group_object_id = azuread_group.CIEM3.id
  member_object_id = data.azuread_user.CIEM3.object_id
}
data "azuread_user" "CIEM4" {
  user_principal_name = format("%s@%s", "todinson", local.domain_name)
}
resource "azuread_group" "CIEM4" {
  display_name = "CIEM4"
  security_enabled = true
  }
resource "azuread_group_member" "CIEM4" {
  group_object_id = azuread_group.CIEM4.id
  member_object_id = data.azuread_user.CIEM4.object_id
}
data "azuread_user" "CIEM5" {
  user_principal_name = format("%s@%s", "tstark", local.domain_name)
}
resource "azuread_group" "CIEM5" {
  display_name = "CIEM5"
  security_enabled = true
  }
resource "azuread_group_member" "CIEM5" {
  group_object_id = azuread_group.CIEM5.id
  member_object_id = data.azuread_user.CIEM5.object_id
}
#######################################################
# The list of permissions added to the custom role
#######################################################

variable "custom_role_permissions1" {
    type = list(string)
    default = [
          "Microsoft.AzureActiveDirectory/b2cDirectories/write",
          "Microsoft.ManagedIdentity/userAssignedIdentities/write",
          "Microsoft.ManagedIdentity/userAssignedIdentities/assign/action",
          "Microsoft.KeyVault/vaults/write",
          "Microsoft.KeyVault/vaults/deploy/action",
          "Microsoft.KeyVault/vaults/accessPolicies/write",
          "Microsoft.Authorization/roleDefinitions/write",
          "Microsoft.Authorization/roleAssignments/write",
          "Microsoft.Authorization/policySetDefinitions/write",
          "Microsoft.Authorization/policyExemptions/write",
          "Microsoft.Authorization/policyDefinitions/write",
          "Microsoft.Authorization/policyAssignments/resourceManagementPrivateLinks/privateEndpointConnections/write",
          "Microsoft.Authorization/policyAssignments/resourceManagementPrivateLinks/privateEndpointConnectionProxies/write",
          "Microsoft.Authorization/policyAssignments/resourceManagementPrivateLinks/write",
          "Microsoft.Authorization/policyAssignments/privateLinkAssociations/write",
          "Microsoft.Authorization/policyAssignments/write",
          "Microsoft.Authorization/locks/write",
          "Microsoft.Authorization/denyAssignments/write",
          "Microsoft.Authorization/classicAdministrators/write"
    ]
}
variable "custom_role_permissions2" {
type = list(string)
    default = [
          "Microsoft.AzureActiveDirectory/b2cDirectories/write",
          "Microsoft.ManagedIdentity/userAssignedIdentities/write",
          "Microsoft.ManagedIdentity/userAssignedIdentities/assign/action",
          "Microsoft.KeyVault/vaults/read",
          "Microsoft.KeyVault/vaults/write",
          "Microsoft.KeyVault/vaults/deploy/action",
          "Microsoft.KeyVault/vaults/accessPolicies/write",
          "Microsoft.Authorization/roleDefinitions/write",
          "Microsoft.Authorization/roleAssignments/write",
          "Microsoft.Authorization/policySetDefinitions/write",
          "Microsoft.Authorization/classicAdministrators/write"
    ]
}
#######################################################
# Setting up custom roles
#######################################################

resource "azurerm_role_definition" "risky_not_actions" {
  name        = "CIEM risky_not_actions role"
  scope       = data.azurerm_subscription.current.id
  description = "CIEM risky not actions role created via Terraform"
  permissions {
    actions = var.custom_role_permissions2
    not_actions = [
          "Microsoft.AzureActiveDirectory/b2cDirectories/*",
          "Microsoft.ManagedIdentity/userAssignedIdentities/assign/*",
          "Microsoft.KeyVault/vaults/*",
          "Microsoft.Authorization/roleDefinitions/*"
    ]
  }
  timeouts {
    create = "5m"
    read = "5m"
  }
}
resource "azurerm_role_definition" "risky_actions_role" {
  name        = "CIEM risky_actions_role"
  scope       = data.azurerm_subscription.current.id
  description = "CIEM risky role created via Terraform"
  permissions {
    actions = var.custom_role_permissions1
    not_actions = []
  }
  timeouts {
    create = "5m"
    read = "5m"
  }
}
resource "azurerm_role_definition" "deny_all_role" {
  name        = "CIEM deny_all_role"
  scope       = data.azurerm_subscription.current.id
  description = "CIEM risky role created via Terraform"
  permissions {
    actions = []
    not_actions = ["*"]
  }
  timeouts {
    create = "5m"
    read = "5m"
  }
}
resource "azurerm_role_definition" "custom_owner_role" {
  name        = "CIEM custom_owner_role"
  scope       = data.azurerm_subscription.current.id
  description = "CIEM custom owner role created via Terraform"
  permissions {
    actions = ["*"]
    not_actions = []
  }
  timeouts {
    create = "5m"
    read = "5m"
  }
}
#######################################################
# Custom Role Assignment - Users
#######################################################
data "azuread_user" "risky_action_users" {
  user_principal_name = format("%s@%s", "acurry", local.domain_name)
}
resource "azurerm_role_assignment" "risky_actions_role" {
  scope       = data.azurerm_subscription.current.id
  principal_id = data.azuread_user.risky_action_users.object_id
  role_definition_id = azurerm_role_definition.risky_actions_role.role_definition_resource_id
}
data "azuread_user" "risky_not_action_users" {
  user_principal_name = format("%s@%s", "ballen", local.domain_name)
}
resource "azurerm_role_assignment" "risky_not_actions" {
  scope       = data.azurerm_subscription.current.id
  principal_id = data.azuread_user.risky_not_action_users.object_id
  role_definition_id = azurerm_role_definition.risky_not_actions.role_definition_resource_id
}
data "azuread_user" "deny_all_role_users" {
  user_principal_name = format("%s@%s", "bbanner", local.domain_name)
}
resource "azurerm_role_assignment" "deny_all_role" {
  scope       = data.azurerm_subscription.current.id
  principal_id = data.azuread_user.deny_all_role_users.object_id
  role_definition_id = azurerm_role_definition.deny_all_role.role_definition_resource_id
}
data "azuread_user" "custom_owner_users" {
  user_principal_name = format("%s@%s", "nromanoff", local.domain_name)
}
resource "azurerm_role_assignment" "custom_owner_role" {
  scope       = data.azurerm_subscription.current.id
  principal_id = data.azuread_user.custom_owner_users.object_id
  role_definition_id = azurerm_role_definition.custom_owner_role.role_definition_resource_id
}
resource "azurerm_role_assignment" "deny_all_role2" {
  scope       = data.azurerm_subscription.current.id
  principal_id = data.azuread_user.Built_In_Owner2.object_id
  role_definition_id = azurerm_role_definition.deny_all_role.role_definition_resource_id
}
#######################################################
# Custom Role Assignment - Service Principals
#######################################################
resource "azurerm_role_assignment" "assignments_ownerdenyall2" {
  scope                = data.azurerm_subscription.current.id
  role_definition_id   = azurerm_role_definition.deny_all_role.role_definition_resource_id
  principal_id         = azuread_service_principal.serviceprinciple_ownerdenyall.object_id
}
#######################################################
# Custom Role Assignment - Groups
#######################################################
resource "azurerm_role_assignment" "CIEM1" {
  scope       = data.azurerm_subscription.current.id
  role_definition_id = azurerm_role_definition.risky_actions_role.role_definition_resource_id
  principal_id = azuread_group.CIEM1.id
}
resource "azurerm_role_assignment" "CIEM2" {
  scope       = data.azurerm_subscription.current.id
  role_definition_id = azurerm_role_definition.risky_not_actions.role_definition_resource_id
  principal_id = azuread_group.CIEM2.id
}
resource "azurerm_role_assignment" "CIEM3" {
  scope       = data.azurerm_subscription.current.id
  role_definition_id = azurerm_role_definition.deny_all_role.role_definition_resource_id
  principal_id = azuread_group.CIEM3.id
}
resource "azurerm_role_assignment" "CIEM4" {
  scope       = data.azurerm_subscription.current.id
  role_definition_id = azurerm_role_definition.custom_owner_role.role_definition_resource_id
  principal_id = azuread_group.CIEM4.id
}
resource "azurerm_role_assignment" "CIEM5" {
  scope       = data.azurerm_subscription.current.id
  role_definition_name = "Owner"
  principal_id = azuread_group.CIEM5.id
}
#######################################################
# Built-In Role Assignment - Service Principals
#######################################################
resource "azurerm_role_assignment" "assignments_owner" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.serviceprinciple_owner.object_id
}
resource "azurerm_role_assignment" "assignments_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.serviceprinciple_contrbutor.object_id
}
resource "azurerm_role_assignment" "assignments_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.serviceprinciple_reader.object_id
}
resource "azurerm_role_assignment" "assignments_keyvault" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Key Vault Contributor"
  principal_id         = azuread_service_principal.serviceprinciple_keyvault.object_id
}
resource "azurerm_role_assignment" "assignments_ownerdenyall1" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.serviceprinciple_ownerdenyall.object_id
}
#######################################################
# Built-In Role Assignment - Users
#######################################################
data "azuread_user" "Built_In_Owner" {
  user_principal_name = format("%s@%s", "bwayne", local.domain_name)
}
resource "azurerm_role_assignment" "Built_In_Owner_toUser" {
  scope       = data.azurerm_subscription.current.id
  principal_id = data.azuread_user.Built_In_Owner.object_id
  role_definition_name = "Owner"
}
data "azuread_user" "Built_In_Contributor" {
  user_principal_name = format("%s@%s", "cdanvers", local.domain_name)
}
resource "azurerm_role_assignment" "Built_In_Contributor_toUser" {
  scope       = data.azurerm_subscription.current.id
  principal_id = data.azuread_user.Built_In_Contributor.object_id
  role_definition_name = "Contributor" 
}
data "azuread_user" "Built_In_KeyVault" {
  user_principal_name = format("%s@%s", "ckent", local.domain_name)
}
resource "azurerm_role_assignment" "Built_In_KeyVault_toUser" {
  scope       = data.azurerm_subscription.current.id
  principal_id = data.azuread_user.Built_In_KeyVault.object_id
  role_definition_name = "Key Vault Contributor"
}
data "azuread_user" "Built_In_Reader" {
  user_principal_name = format("%s@%s", "dprince", local.domain_name)
}
resource "azurerm_role_assignment" "Built_In_Reader_toUser" {
  scope       = data.azurerm_subscription.current.id
  principal_id = data.azuread_user.Built_In_Reader.object_id
  role_definition_name = "Reader" 
}
data "azuread_user" "Built_In_KeyVaultReader" {
  user_principal_name = format("%s@%s", "wwilson", local.domain_name)
}
resource "azurerm_role_assignment" "Built_In_KeyVault_Reader_toUser" {
  scope       = data.azurerm_subscription.current.id
  principal_id = data.azuread_user.Built_In_KeyVaultReader.object_id
  role_definition_name = "Key Vault Reader" 
}
resource "azurerm_management_group" "ManagementGroup" {
  display_name = "CIEM-Test-ManagementGroup"

  subscription_ids = [
    data.azurerm_subscription.current.subscription_id,
  ]
}
data "azuread_user" "Built_In_Owner2" {
  user_principal_name = format("%s@%s", "wmaximoff", local.domain_name)
}
resource "azurerm_role_assignment" "Built_In_Owner2_toUser" {
  scope = azurerm_management_group.ManagementGroup.id
  principal_id = data.azuread_user.Built_In_Owner2.object_id
  role_definition_name = "Owner" 
 # condition = "()"
}

##############################################################
# Create Azure Linux VM as a System Assigned Managed Identity
##############################################################
module "azurevm" {
  source = "./modules/azurevm/"
}
/*
#module "cosmosdb" {
#  source = "./modules/cosmosdb/"
#}
*/
module "privesc-paths" {
  source = "./modules/privesc-paths/"
}
module "azurevm_user_assigned" {
  source = "./modules/azurevm_user_assigned/"
}
