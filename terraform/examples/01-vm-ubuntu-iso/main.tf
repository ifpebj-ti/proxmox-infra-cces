# Exemplo 01 — VM Ubuntu Server (instalação via ISO)
#
# Cria uma VM pronta para instalar Ubuntu Server manualmente.
# Configurações otimizadas: q35, UEFI, VirtIO, QEMU Guest Agent habilitado.

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
