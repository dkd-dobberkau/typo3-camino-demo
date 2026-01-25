variable "elestio_email" {
  description = "Elestio account email"
  type        = string
}

variable "elestio_api_token" {
  description = "Elestio API token (from https://dash.elest.io/account/security)"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Name of the Elestio project"
  type        = string
  default     = "TYPO3 Camino Demo"
}

variable "technical_emails" {
  description = "List of technical contact emails"
  type        = list(string)
  default     = []
}

variable "admin_email" {
  description = "Admin email for TYPO3 and notifications"
  type        = string
}

variable "software_password" {
  description = "Password for database and TYPO3 admin"
  type        = string
  sensitive   = true
}

variable "server_type" {
  description = "Server size (SMALL-1C-2G, MEDIUM-2C-4G, etc.)"
  type        = string
  default     = "SMALL-1C-2G"
}

variable "cloud_provider" {
  description = "Cloud provider (hetzner, digitalocean, vultr, linode, aws-lightsail)"
  type        = string
  default     = "hetzner"
}

variable "datacenter" {
  description = "Datacenter location"
  type        = string
  default     = "fsn1"  # Falkenstein, Germany
}
