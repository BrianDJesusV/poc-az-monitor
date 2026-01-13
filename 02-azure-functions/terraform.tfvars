# Configuration for Scenario 2: Azure Functions
# Active configuration file

resource_group_name = "rg-azmon-poc-mexicocentral"
location            = "mexicocentral"  # Back to Mexico Central - has quota
law_name            = "law-azmon-poc-mexicocentral"
environment         = "poc"

tags = {
  environment = "poc"
  project     = "azure-monitor"
  scenario    = "functions-serverless"
  managed-by  = "terraform"
  region      = "mexicocentral"
}
