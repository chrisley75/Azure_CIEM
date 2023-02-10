resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

# Create virtual network
resource "azurerm_virtual_network" "CIEM_terraform_network" {
  name                = "CIEMVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "CIEM_terraform_subnet" {
  name                 = "CIEMSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.CIEM_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "CIEM_terraform_public_ip" {
  name                = "CIEMPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "CIEM_terraform_nsg" {
  name                = "CIEMNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "CIEM_terraform_nic" {
  name                = "CIEMNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "CIEM_nic_configuration"
    subnet_id                     = azurerm_subnet.CIEM_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.CIEM_terraform_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.CIEM_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.CIEM_terraform_nsg.id
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "CIEM_terraform_vm" {
  name                  = "CIEMVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.CIEM_terraform_nic.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "CIEMOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "CIEMVM"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  identity {
    type = "SystemAssigned"
  }
  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }
}
data "azurerm_subscription" "current" {
}
resource "azurerm_role_assignment" "managed_identity_owner" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Owner"
  principal_id = azurerm_linux_virtual_machine.CIEM_terraform_vm.identity[0].principal_id
}
resource "azurerm_role_assignment" "managed_identity_owner2" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id = azurerm_linux_virtual_machine.CIEM_terraform_vm.identity[0].principal_id
}