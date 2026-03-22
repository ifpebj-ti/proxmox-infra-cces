# 02 — VM Ubuntu + Ansible (QEMU Guest Agent + Docker)

Cria uma VM Ubuntu e provisiona automaticamente com Ansible, instalando QEMU Guest Agent e Docker Engine.

Usa o playbook compartilhado em `ansible/playbooks/setup-vm.yml`.

## Pré-requisitos

No seu notebook (onde roda o Terraform):

```bash
# Instalar Ansible
sudo apt install ansible -y
```

## Fluxo em 2 Etapas

### Etapa 1 — Criar a VM

```bash
cd terraform/examples/02-vm-ansible/

# Configurar variáveis (sem preencher vm_ssh_host ainda)
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# Criar a VM
terraform init
terraform plan
terraform apply
```

Acesse o console no Proxmox e instale o Ubuntu Server normalmente.
Durante a instalação, habilite o **OpenSSH Server** e configure um usuário.
Após a instalação, instale o QEMU Guest Agent dentro da VM:

```bash
sudo apt install qemu-guest-agent -y
sudo systemctl enable --now qemu-guest-agent
```

### Etapa 2 — Provisionar com Ansible

Após instalar o SO e a VM estar acessível via SSH:

1. **Copie sua chave SSH** para a VM (será pedida a senha do usuário):
   ```bash
   ssh-copy-id usuario@192.168.10.XXX
   ```

2. **Configure o sudo** — escolha **uma** das opções:

   **Opção A (recomendada para automação):** Sudo sem senha — não precisa colocar `vm_sudo_password` no `.tfvars`:
   ```bash
   ssh usuario@192.168.10.XXX 'echo "usuario ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/usuario'
   ```

   **Opção B:** Passar a senha do sudo via Terraform — adicione no `.tfvars`:
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

   # Executar Ansible
   terraform apply
   ```

O Terraform detecta que `vm_ssh_host` foi preenchido e executa automaticamente o playbook Ansible que instala:
- **QEMU Guest Agent** — comunicação Proxmox ↔ VM
- **Docker Engine** — com Docker Compose, Buildx e repositório oficial

## Alternativa: rodar Ansible manualmente

Se preferir rodar o Ansible fora do Terraform:

```bash
cd ../../..   # Volta à raiz do repositório

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
  -i '192.168.10.XXX,' \
  -u ubuntu \
  --private-key ~/.ssh/id_rsa \
  ansible/playbooks/setup-vm.yml
```

## Para destruir

```bash
terraform destroy
```
