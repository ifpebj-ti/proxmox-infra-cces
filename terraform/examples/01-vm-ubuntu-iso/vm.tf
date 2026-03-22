# VM Ubuntu Server — instalação via ISO
# Configurações otimizadas para o Proxmox CCES/IFPE.

resource "proxmox_virtual_environment_vm" "ubuntu" {
  name      = var.vm_name
  node_name = var.proxmox_node
  pool_id   = var.proxmox_pool

  # Hardware virtual moderno (necessário para GPU passthrough futuro)
  machine = "q35"
  bios    = "ovmf"

  # SCSI controller de alta performance
  scsi_hardware = "virtio-scsi-single"

  # QEMU Guest Agent — habilita desligamento limpo, IP visível, snapshots consistentes
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

  # Disco EFI (obrigatório para UEFI/OVMF)
  efi_disk {
    datastore_id = "local-zfs"
    type         = "4m"
  }

  # Disco principal da VM (NVMe — alta performance)
  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    size         = var.vm_disk_size
    file_format  = "raw"
    iothread     = true
    discard      = "on"
  }

  # ISO do Ubuntu montada como CD-ROM
  cdrom {
    file_id   = "datapool-templates:iso/${var.iso_file}"
    interface = "ide2"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # Boot: disco primeiro, CD-ROM depois (na 1ª vez, cairá no instalador)
  boot_order = ["scsi0", "ide2"]

  started = true

  tags = ["terraform", "ubuntu"]
}

output "vm_id" {
  description = "ID da VM criada"
  value       = proxmox_virtual_environment_vm.ubuntu.vm_id
}

output "vm_name" {
  description = "Nome da VM"
  value       = proxmox_virtual_environment_vm.ubuntu.name
}
