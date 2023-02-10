terraform {
  required_providers {
    azuread = {
      version = "=2.29.0"
    }
    azurerm = {
      version = "=3.32.0"
    }
    random = {
      version = "=3.1.0"
    }
    time = {
      version = "=0.7.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}
