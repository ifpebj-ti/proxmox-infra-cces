# 03 — VM Ubuntu + GPU Passthrough + Ansible

Cria uma VM com GPU NVIDIA RTX 4060 (passthrough direto) e provisiona com Ansible (QEMU Guest Agent + Docker).

## Pré-requisitos

- **Pool**: `researchers` (alunos **não** têm acesso a GPU)
- **GPU livre**: Verifique que nenhuma outra VM está usando a GPU escolhida (cada GPU é exclusiva por VM)
- **Ansible instalado** no notebook: `sudo apt install ansible -y`

## Fluxo em 2 Etapas

### Etapa 1 — Criar a VM com GPU

```bash
cd terraform/examples/03-vm-gpu-ansible/

cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars   # Preencha token, escolha a GPU

terraform init
terraform plan
terraform apply
```

Acesse o console no Proxmox e instale o Ubuntu Server.
Acesse o console no Proxmox e instale o Ubuntu Server normalmente.
Durante a instalação, habilite o **OpenSSH Server** e configure um usuário.
Após a instalação, instale o QEMU Guest Agent dentro da VM:

```bash
sudo apt install qemu-guest-agent -y
sudo systemctl enable --now qemu-guest-agent
```

### Etapa 2 — Ansible + Drivers NVIDIA

Após instalar o SO e a VM estar acessível via SSH:

1. **Copie sua chave SSH** para a VM (será pedida a senha do usuário):
   ```bash
   ssh-copy-id usuario@192.168.10.XXX
   ```

2. **Configure o sudo** — escolha **uma** das opções:

   **Opção A (recomendada para automação):** Sudo sem senha:
   ```bash
   ssh usuario@192.168.10.XXX 'echo "usuario ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/usuario'
   ```

   **Opção B:** Passar a senha via Terraform — adicione no `.tfvars`:
   ```hcl
   vm_sudo_password = "sua-senha-sudo"
   ```

3. **Preencha o `.tfvars`** e aplique:
   ```bash
   # Edite terraform.tfvars e descomente/preencha:
   #   vm_ssh_host        = "192.168.10.XXX"
   #   vm_ssh_user        = "usuario"
   #   vm_ssh_private_key = "~/.ssh/id_rsa"
   #   vm_sudo_password   = ""              ← Opção A (NOPASSWD)
   #   vm_sudo_password   = "senha-sudo"    ← Opção B

   nano terraform.tfvars

   # Executar Ansible (instala qemu-guest-agent + Docker)
   terraform apply
   ```

Depois, **dentro da VM**, instale os drivers NVIDIA:

```bash
sudo apt update
sudo apt install -y nvidia-driver-590
sudo reboot

# Após reiniciar, verificar:
nvidia-smi
```

## Escolha da GPU

| Mapping | Slot | Conexão | Latência |
|---|---|---|---|
| `gpu-rtx4060-01` | Slot 1 | PCIe direto do CPU | Menor |
| `gpu-rtx4060-02` | Slot 2 | PCIe via chipset X670E | Levemente maior |

> **Lembrete**: Apenas 1 VM pode usar cada GPU por vez. Com 2 GPUs, no máximo 2 VMs com GPU rodam simultaneamente.

## Para destruir

```bash
terraform destroy
```
