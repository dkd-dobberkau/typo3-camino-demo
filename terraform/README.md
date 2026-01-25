# Terraform Deployment for Elestio

Automated infrastructure deployment for TYPO3 Camino Demo on Elestio.

## Prerequisites

1. [Terraform](https://terraform.io) >= 1.0
2. Elestio account with API token from https://dash.elest.io/account/security

## Quick Start

```bash
cd terraform

# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your credentials

# Initialize and deploy
terraform init
terraform plan
terraform apply
```

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `elestio_email` | Your Elestio account email | - |
| `elestio_api_token` | API token from Elestio dashboard | - |
| `software_password` | Password for DB and TYPO3 admin | - |
| `server_type` | VM size | `SMALL-1C-2G` |
| `cloud_provider` | Cloud provider | `hetzner` |
| `datacenter` | Datacenter location | `fsn1` |

## Server Types

| Type | vCPU | RAM | Monthly (approx.) |
|------|------|-----|-------------------|
| SMALL-1C-2G | 1 | 2 GB | ~$10 |
| MEDIUM-2C-4G | 2 | 4 GB | ~$20 |
| BIG-4C-8G | 4 | 8 GB | ~$40 |

## Destroy

```bash
terraform destroy
```
