variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default = "rg-04-todoapp"
}

variable "location" {
  type        = string
  description = "Resource group location"
  default = "westeurope"
}

variable "cosmosdb_account_name" {
  type        = string
  description = "Cosmos db account name"
  default = "db-04-todoapp"
}

variable "app_service_plan_name" {
  type        = string
  default = "app-plan-04-todoapp"
}

variable "webapp_name" {
  type        = string
  default = "webapp-04-todoapp"
}