# VM de teste mínima — apenas para validar que a API e permissões funcionam.
# Após confirmar que funciona, destrua com: terraform destroy

resource "proxmox_virtual_environment_vm" "test_api" {
  name      = "test-terraform-api"
  node_name = var.proxmox_node
  vm_id     = 9999
  pool_id   = var.proxmox_pool

  # VM mínima — sem OS, só para testar provisionamento
  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
  }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    size         = 4
    file_format  = "raw"
  }

  network_device {
    bridge = "vmbr0"
  }

  # Não iniciar automaticamente (é só um teste)
  started = false

  tags = ["teste", "terraform"]
}

output "test_vm_id" {
  description = "ID da VM de teste criada"
  value       = proxmox_virtual_environment_vm.test_api.vm_id
}

output "test_vm_name" {
  description = "Nome da VM de teste criada"
  value       = proxmox_virtual_environment_vm.test_api.name
}
