# VM Ubuntu Server com GPU Passthrough
# q35 + UEFI — obrigatório para GPU passthrough NVIDIA.

resource "proxmox_virtual_environment_vm" "ubuntu_gpu" {
  name      = var.vm_name
  node_name = var.proxmox_node
  pool_id   = var.proxmox_pool

  machine       = "q35"
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-single"

  agent {
    enabled = true
  }

  # CPU type "host" — obrigatório para passthrough (expõe instruções reais)
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

  # GPU Passthrough via Resource Mapping
  # Usa o nome do mapeamento criado no Proxmox (Datacenter → Resource Mappings).
  # Opções: gpu-rtx4060-01 (Slot 1, PCIe CPU) ou gpu-rtx4060-02 (Slot 2, PCIe Chipset)
  hostpci {
    device  = "hostpci0"
    mapping = var.gpu_mapping
    pcie    = true
    rombar  = true
    xvga    = false  # true = Primary GPU (vídeo no monitor físico)
  }

  boot_order = ["scsi0", "ide2"]

  started = true

  tags = ["terraform", "ubuntu", "gpu", "ansible"]
}

output "vm_id" {
  description = "ID da VM criada"
  value       = proxmox_virtual_environment_vm.ubuntu_gpu.vm_id
}

output "vm_name" {
  description = "Nome da VM"
  value       = proxmox_virtual_environment_vm.ubuntu_gpu.name
}

output "gpu_mapping" {
  description = "GPU mapeada para esta VM"
  value       = var.gpu_mapping
}
