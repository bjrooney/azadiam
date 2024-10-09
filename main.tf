# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.4"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a Resource Group
resource "azurerm_resource_group" "example" {
  name     = "aks-rg"
  location = "West Europe"
}

# Create an Azure Active Directory Group for AKS Admins
resource "azuread_group" "aks_admins" {
  display_name     = "aks-admins"
  mail_nickname    = "aks-admins"
  security_enabled = true
}

# Create an AKS Cluster with Azure AD Integration
resource "azurerm_kubernetes_cluster" "example" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "aksexample"

  # Azure AD Integration
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    admin_group_object_ids = azuread_group.aks_admins.id
  }

  # Identity block
  identity {
    type = "SystemAssigned"
  }

  # Choose your preferred Kubernetes version
  kubernetes_version = "1.31"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  # Enable OIDC issuer for Workload Identity
  oidc_issuer_enabled = true

  # Optional: Enable HTTP Application Routing
  http_application_routing_enabled = true
}

# Output the AKS Cluster Name and OIDC Issuer URL
output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.example.name
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.example.oidc_issuer_url
}

