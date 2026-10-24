# Busca o template no nó de origem quando template_id = 0.
data "proxmox_virtual_environment_vms" "templates" {
  count     = var.template_id == 0 ? 1 : 0
  node_name = var.template_node
}

locals {
  template_id = var.template_id != 0 ? var.template_id : one([
    for vm in try(data.proxmox_virtual_environment_vms.templates[0].vms, []) :
    vm.vm_id if vm.name == var.template_name
  ])
}

resource "proxmox_virtual_environment_vm" "ubuntu" {
  name      = var.vm_name
  node_name = var.proxmox_node
  pool_id   = var.proxmox_pool

  clone {
    vm_id        = local.template_id
    node_name    = var.template_node
    datastore_id = var.clone_datastore_id
  }

  cpu {
    cores = var.vm_cores
    type  = "host"
  }

  memory {
    dedicated = var.vm_memory
  }

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

    user_account {
      username = var.vm_user
      keys     = [trimspace(file(pathexpand(var.ssh_public_key_file)))]
    }

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
  tags    = ["terraform", "ubuntu", "cloud-init", "pve02"]

  lifecycle {
    precondition {
      condition     = local.template_id != null
      error_message = "Template '${var.template_name}' não encontrado no nó de origem '${var.template_node}'."
    }
  }
}

output "vm_id" {
  description = "ID da VM criada"
  value       = proxmox_virtual_environment_vm.ubuntu.vm_id
}

output "vm_name" {
  description = "Nome da VM"
  value       = proxmox_virtual_environment_vm.ubuntu.name
}

output "vm_ipv4" {
  description = "Endereço IPv4 publicado pelo QEMU Guest Agent"
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
