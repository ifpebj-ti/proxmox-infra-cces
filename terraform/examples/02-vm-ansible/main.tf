# Exemplo 02 — VM Ubuntu + Ansible (QEMU Guest Agent + Docker)
#
# Cria uma VM Ubuntu e, após instalação do SO, executa o playbook Ansible
# compartilhado que instala QEMU Guest Agent e Docker.
#
# Fluxo em 2 etapas:
#   1. terraform apply                → cria a VM (instale o SO manualmente)
#   2. terraform apply (com vm_ssh_*) → executa Ansible na VM

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
