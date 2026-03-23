# ── Provider ──

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
  description = "Nome do nó Proxmox"
  type        = string
}

variable "proxmox_pool" {
  description = "Resource pool (researchers ou students)"
  type        = string
}

# ── Template ──

variable "template_name" {
  description = "Nome do template cloud-init (usado se template_id = 0)"
  type        = string
  default     = "ubuntu-2404-cloud"
}

variable "template_id" {
  description = "ID do template no Proxmox (ex: 9000). Se 0, busca pelo nome."
  type        = number
  default     = 0
}

# ── VM ──

variable "vm_name" {
  description = "Nome da VM"
  type        = string
  default     = "ubuntu-cloud"
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
  description = "Tamanho do disco em GB (expandido automaticamente do template)"
  type        = number
  default     = 32
}

# ── Cloud-Init ──

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
  description = "ID do snippet vendor-data pré-instalado pelo admin (ex: datapool-templates:snippets/vendor-data-base.yaml)"
  type        = string
  default     = "datapool-templates:snippets/vendor-data-base.yaml"
}

# ── GPU (opcional) ──

variable "gpu_mapping" {
  description = "Nome do Resource Mapping da GPU (ex: gpu-rtx4060-01). Deixe vazio para VM sem GPU."
  type        = string
  default     = ""
}
