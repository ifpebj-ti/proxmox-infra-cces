# Exemplo 03 — VM Ubuntu + GPU Passthrough + Ansible
#
# Cria uma VM com GPU NVIDIA RTX 4060 via Resource Mapping e, após
# instalação do SO, executa o playbook Ansible (QEMU Guest Agent + Docker).
#
# Requer conta com permissão em /mapping/pci (researchers, não students).

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
