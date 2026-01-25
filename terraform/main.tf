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
  technical_email  = var.admin_email
}

resource "elestio_ci_cd_target" "typo3" {
  project_id    = elestio_project.typo3_camino.id
  server_name   = "typo3-camino"
  server_type   = var.server_type
  provider_name = var.cloud_provider
  datacenter    = var.datacenter
  support_level = "level1"
  admin_email   = var.admin_email
}

output "project_id" {
  description = "Elestio Project ID"
  value       = elestio_project.typo3_camino.id
}

output "target_id" {
  description = "CI/CD Target ID"
  value       = elestio_ci_cd_target.typo3.id
}

output "server_ip" {
  description = "Server IP address"
  value       = elestio_ci_cd_target.typo3.ipv4
}

output "cname" {
  description = "Elestio CNAME (use for TYPO3_BASE_URL)"
  value       = elestio_ci_cd_target.typo3.cname
}

output "typo3_urls" {
  description = "TYPO3 access URLs (after pipeline deployment)"
  value = {
    frontend = "https://${elestio_ci_cd_target.typo3.cname}"
    backend  = "https://${elestio_ci_cd_target.typo3.cname}/typo3"
  }
}

output "next_steps" {
  description = "Manual steps to complete deployment"
  value       = <<-EOT

    CI/CD Target created! Next steps:
    1. Go to https://dash.elest.io/projects/${elestio_project.typo3_camino.id}
    2. Click on the CI/CD target "${elestio_ci_cd_target.typo3.server_name}"
    3. Add Pipeline > Docker Compose
    4. Paste content from: elestio/docker-compose.yml
    5. Set DOMAIN=${elestio_ci_cd_target.typo3.cname}
    6. Deploy!

  EOT
}
