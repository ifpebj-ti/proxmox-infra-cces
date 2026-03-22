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

  # O Proxmox usa certificado autoassinado por padrão.
  # Em produção, configure um certificado válido e remova esta linha.
  insecure = true

  ssh {
    agent = false
  }
}
