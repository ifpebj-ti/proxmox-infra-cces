# Provisionamento com Ansible (etapa 2)
# Só executa quando vm_ssh_host é preenchido (após instalar o SO).

resource "terraform_data" "ansible_provision" {
  count = var.vm_ssh_host != "" ? 1 : 0

  depends_on = [proxmox_virtual_environment_vm.ubuntu]

  triggers_replace = [var.vm_ssh_host]

  provisioner "local-exec" {
    command = <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
        -i '${var.vm_ssh_host},' \
        -u '${var.vm_ssh_user}' \
        --private-key '${var.vm_ssh_private_key}' \
        ${var.vm_sudo_password != "" ? "-e ansible_become_password='${var.vm_sudo_password}'" : ""} \
        --become \
        ../../../ansible/playbooks/setup-vm.yml
    EOT
  }
}

output "ansible_status" {
  description = "Status do provisionamento Ansible"
  value       = var.vm_ssh_host != "" ? "Ansible executado para ${var.vm_ssh_host}" : "Aguardando: preencha vm_ssh_host após instalar o SO"
}
