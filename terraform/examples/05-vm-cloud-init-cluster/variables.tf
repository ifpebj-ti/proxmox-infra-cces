# Provider

variable "proxmox_endpoint" {
  description = "URL da API do Proxmox"
  type        = string
}

variable "proxmox_api_token" {
  description = "API token no formato USER@REALM!TOKENID=SECRET"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Nó de destino da VM"
  type        = string
  default     = "pve02"
}

variable "proxmox_pool" {
  description = "Resource pool da VM"
  type        = string
  default     = "researchers"
}

# Template de origem

variable "template_node" {
  description = "Nó onde está o template de origem"
  type        = string
  default     = "pve01"
}

variable "template_name" {
  description = "Nome do template cloud-init, usado quando template_id = 0"
  type        = string
  default     = "ubuntu-2404-cloud"
}

variable "template_id" {
  description = "ID do template cloud-init"
  type        = number
  default     = 9000
}

variable "clone_datastore_id" {
  description = "Storage local-zfs de destino para os discos clonados no pve02"
  type        = string
  default     = "local-zfs"
}

# VM

variable "vm_name" {
  description = "Nome da VM"
  type        = string
  default     = "ubuntu-cloud-pve02"
}

variable "vm_cores" {
  description = "Número de cores de CPU"
  type        = number
  default     = 8
}

variable "vm_memory" {
  description = "Memória RAM em MB; 65536 equivale a 64 GiB"
  type        = number
  default     = 65536
}

variable "vm_disk_size" {
  description = "Tamanho do disco do sistema em GB"
  type        = number
  default     = 320
}

# Cloud-Init

variable "vm_user" {
  description = "Usuário criado na VM via cloud-init"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_file" {
  description = "Caminho do arquivo da chave SSH pública"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vendor_data_file_id" {
  description = "Snippet cloud-init instalado no storage local do pve02"
  type        = string
  default     = "datapool-templates-pve02:snippets/vendor-data-base.yaml"
}

# GPU passthrough (opcional)

variable "gpu_mapping" {
  description = "Resource Mapping PCI da GPU no pve02; vazio cria VM sem GPU"
  type        = string
  default     = ""
}
