# Provider configuration (if needed)
provider "azurerm" {
  features {}
}

# Define any necessary variables
variables {
  resource_groups = {
    rg-test-1 = {
      name        = "rg-test-1"
      location    = "uksouth"
      create_lock = { kind = "CanNotDelete" }
      localtags   = { "Environment" = "Test" }
    }
  }
  tags = { "Owner" = "DevOps Team" }
}



run "unit_test" {
  command = plan

  assert {
    condition     = azurerm_resource_group.this["rg-test-1"].name == "rg-test-1"
    error_message = "The resource groupname did not match expected"
  }

  assert {
    condition     = azurerm_resource_group.this["rg-test-1"].location == "uksouth"
    error_message = "The resource group location did not match the expected value"
  }

  assert {
    condition     = azurerm_management_lock.resource-group-level["rg-test-1"].lock_level == "CanNotDelete"
    error_message = "The resource group lock level did not match expected"
  }

  assert {
    condition     = azurerm_resource_group.this["rg-test-1"].tags.Environment == "Test"
    error_message = "The resource group local tag 'Environment' did not match the expected value"
  }

  assert {
    condition     = azurerm_resource_group.this["rg-test-1"].tags.Owner == "DevOps Team"
    error_message = "The resource group tag 'Owner' did not match the expected value"
  }
}