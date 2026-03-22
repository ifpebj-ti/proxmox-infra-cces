# VM Ubuntu Server — instalação via ISO

resource "proxmox_virtual_environment_vm" "ubuntu" {
  name      = var.vm_name
  node_name = var.proxmox_node
  pool_id   = var.proxmox_pool

  machine       = "q35"
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-single"

  agent {
    enabled = true
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
    file_format  = "raw"
    iothread     = true
    discard      = "on"
  }

  cdrom {
    file_id   = "datapool-templates:iso/${var.iso_file}"
    interface = "ide2"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  boot_order = ["scsi0", "ide2"]

  started = true

  tags = ["terraform", "ubuntu", "ansible"]
}

output "vm_id" {
  description = "ID da VM criada"
  value       = proxmox_virtual_environment_vm.ubuntu.vm_id
}

output "vm_name" {
  description = "Nome da VM"
  value       = proxmox_virtual_environment_vm.ubuntu.name
}
