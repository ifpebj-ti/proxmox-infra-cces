variable "proxmox_endpoint" {
  description = "URL da API do Proxmox (ex: https://192.168.10.134:8006)"
  type        = string
}

variable "proxmox_api_token" {
  description = "API token no formato USER@REALM!TOKENID=SECRET"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Nome do nó Proxmox (hostname configurado na instalação)"
  type        = string
}

variable "proxmox_pool" {
  description = "Resource pool do Proxmox onde a VM será criada (ex: researchers, students)"
  type        = string
}
