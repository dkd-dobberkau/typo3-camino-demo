terraform {
  required_version = ">= 1.0"

  required_providers {
    elestio = {
      source  = "elestio/elestio"
      version = "~> 0.19"
    }
  }
}

provider "elestio" {
  email     = var.elestio_email
  api_token = var.elestio_api_token
}

resource "elestio_project" "typo3_camino" {
  name             = var.project_name
  description      = "TYPO3 v14 with Camino Theme Demo"
  technical_emails = var.technical_emails
}

resource "elestio_custom" "typo3" {
  project_id    = elestio_project.typo3_camino.id
  version       = "latest"
  server_name   = "typo3-camino"
  server_type   = var.server_type
  provider_name = var.cloud_provider
  datacenter    = var.datacenter

  support_level = "level1"
  admin_email   = var.admin_email

  docker_compose = templatefile("${path.module}/docker-compose.tftpl", {
    domain           = elestio_custom.typo3.cname
    software_password = var.software_password
    admin_email      = var.admin_email
  })
}

output "typo3_url" {
  description = "TYPO3 Frontend URL"
  value       = "https://${elestio_custom.typo3.cname}"
}

output "typo3_backend_url" {
  description = "TYPO3 Backend URL"
  value       = "https://${elestio_custom.typo3.cname}/typo3"
}

output "admin_credentials" {
  description = "Admin login credentials"
  value       = "Username: admin / Password: (see SOFTWARE_PASSWORD)"
  sensitive   = false
}
