variable "prod_db_user" {
  description = "The username for the production database"
  type        = string
}

variable "prod_db_password" {
  description = "The password for the production database"
  type        = string
}

variable "prod_db_port" {
  description = "The port for the production database"
  type        = string
  default     = "10255" # Standard CosmosDB Port
}

variable "prod_db_name" {
  description = "The name of the production database"
  type        = string
}
