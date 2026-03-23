# Busca dinâmica do template por nome (se template_id não for informado)

data "proxmox_virtual_environment_vms" "templates" {
  count     = var.template_id == 0 ? 1 : 0
  node_name = var.proxmox_node
}

locals {
  template_id = var.template_id != 0 ? var.template_id : one([
    for vm in try(data.proxmox_virtual_environment_vms.templates[0].vms, []) :
    vm.vm_id if vm.name == var.template_name
  ])
}

# ── VM clonada do template com cloud-init ──
#
# Configuração por-VM (user, SSH key) via bloco initialization.user_account (API).
# Pacotes do sistema (Docker, NVIDIA) via vendor-data pré-instalado pelo admin.
# Nenhum upload de arquivo é feito — tudo funciona via API do Proxmox.

resource "proxmox_virtual_environment_vm" "ubuntu" {
  name      = var.vm_name
  node_name = var.proxmox_node
  pool_id   = var.proxmox_pool

  clone {
    vm_id = local.template_id
  }

  cpu {
    cores = var.vm_cores
    type  = "host"
  }

  memory {
    dedicated = var.vm_memory
  }

  # EFI disk (herdado do template, precisa indicar o storage)
  efi_disk {
    datastore_id = "local-zfs"
    type         = "4m"
  }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    size         = var.vm_disk_size
    iothread     = true
    discard      = "on"
  }

  # GPU Passthrough via Resource Mapping (opcional)
  # Só adiciona se gpu_mapping for preenchido.
  dynamic "hostpci" {
    for_each = var.gpu_mapping != "" ? [1] : []
    content {
      device  = "hostpci0"
      mapping = var.gpu_mapping
      pcie    = true
      rombar  = true
      xvga    = false
    }
  }

  initialization {
    datastore_id = "local-zfs"

    # Configuração do usuário (via API — sem SSH ao host)
    user_account {
      username = var.vm_user
      keys     = [trimspace(file(pathexpand(var.ssh_public_key_file)))]
    }

    # Vendor-data: snippet pré-instalado pelo admin no Proxmox
    # Referência: "datapool-templates:snippets/vendor-data-base.yaml"
    #          ou "datapool-templates:snippets/vendor-data-gpu.yaml"
    vendor_data_file_id = var.vendor_data_file_id

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  agent {
    enabled = true
  }

  started = true

  tags = ["terraform", "ubuntu", "cloud-init"]

  lifecycle {
    precondition {
      condition     = local.template_id != null
      error_message = "Template '${var.template_name}' não encontrado no nó '${var.proxmox_node}'. Execute o script cloud-init/create-template.sh primeiro."
    }
  }
}

# ── Outputs ──

output "vm_id" {
  description = "ID da VM criada"
  value       = proxmox_virtual_environment_vm.ubuntu.vm_id
}

output "vm_name" {
  description = "Nome da VM"
  value       = proxmox_virtual_environment_vm.ubuntu.name
}

output "vm_ipv4" {
  description = "Endereço IPv4 da VM (disponível após boot + QEMU Guest Agent)"
  value       = try(proxmox_virtual_environment_vm.ubuntu.ipv4_addresses[1][0], "Aguardando QEMU Guest Agent...")
}

output "ssh_command" {
  description = "Comando SSH para acessar a VM"
  value       = "ssh ${var.vm_user}@${try(proxmox_virtual_environment_vm.ubuntu.ipv4_addresses[1][0], "<IP>")}"
}

output "gpu_mapping" {
  description = "GPU mapeada para esta VM"
  value       = var.gpu_mapping
}