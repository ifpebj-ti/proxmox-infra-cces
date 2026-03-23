# Exemplo 04 — VM Ubuntu Cloud-Init (deploy automatizado)
#
# Clona um template cloud-init e configura a VM automaticamente.
# Não requer instalação manual do SO.

terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true

  ssh {
    agent = false
    
  }
}
