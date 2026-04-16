variable "proxmox_endpoint" {
  description = "URL da API do Proxmox (ex: https://10.26.7.10:8006)"
  type        = string
}

variable "proxmox_api_token" {
  description = "API token no formato USER@REALM!TOKENID=SECRET"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Nome do nó Proxmox"
  type        = string
}

variable "proxmox_pool" {
  description = "Resource pool (researchers ou students)"
  type        = string
}

variable "vm_name" {
  description = "Nome da VM"
  type        = string
  default     = "ubuntu-server"
}

variable "vm_cores" {
  description = "Número de cores de CPU"
  type        = number
  default     = 4
}

variable "vm_memory" {
  description = "Memória RAM em MB"
  type        = number
  default     = 4096
}

variable "vm_disk_size" {
  description = "Tamanho do disco em GB"
  type        = number
  default     = 32
}

variable "iso_file" {
  description = "Nome do arquivo ISO no storage datapool-templates"
  type        = string
  default     = "ubuntu-24.04.4-live-server-amd64.iso"
}
