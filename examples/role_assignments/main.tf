terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  min = 0
  max = length(module.regions.regions) - 1
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

# This is the module call
module "test" {
  source = "../../"
  # ...
  name     = module.naming.resource_group.name_unique
  location = module.regions.regions[random_integer.region_index.result].name

  role_assignments = {
    DataBricks = {
      role_definition_id_or_name = "Storage Account Contributor"
      principal_id               = data.azuread_service_principal.this.object_id
      description                = "Allow Azure DataBricks the Storage Account Contributor role in the resource group"
    }
  }

  tags = {
    environment = "test"
  }
}
