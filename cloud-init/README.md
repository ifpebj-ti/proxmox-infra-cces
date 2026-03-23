# Cloud-Init — Templates e Snippets para Proxmox

Scripts e arquivos para cloud-init no Proxmox.
Templates permitem clonar VMs pré-instaladas em segundos (sem instalar o SO manualmente).
Snippets vendor-data configuram pacotes automaticamente no primeiro boot (Docker, NVIDIA, etc.).

## O que é Cloud-Init?

Cloud-init é o padrão da indústria para inicialização de VMs em nuvem.
Na primeira boot, ele configura automaticamente:
- **Usuário** + chave SSH + sudo sem senha
- **Hostname** e timezone
- **Pacotes** (Docker, qemu-guest-agent, drivers NVIDIA, etc.)
- **Rede** (DHCP ou IP estático)

É o mesmo mecanismo usado pela AWS, Azure, GCP e DigitalOcean.

## Pré-requisitos

- Acesso **root** ao host Proxmox (via SSH ou console)
- Storage `local-zfs` disponível (ou outro, ajuste o parâmetro)
- Storage `datapool-templates` com conteúdo **Snippets** habilitado
- Conexão com a internet no Proxmox (para download da imagem)

## 1. Criar o Template (uma vez)

### Copie e execute no Proxmox

```bash
# Do admin, envie o script via SCP:
scp cloud-init/create-template.sh root@192.168.10.134:/tmp/

# Via SSH no Proxmox:
ssh root@192.168.10.134 "bash /tmp/create-template.sh"
```

O script usa os seguintes padrões:

| Parâmetro | Padrão | Descrição |
|---|---|---|
| `TEMPLATE_ID` | 9000 | ID da VM/template no Proxmox |
| `TEMPLATE_NAME` | ubuntu-2404-cloud | Nome do template |
| `STORAGE` | local-zfs | Storage para o disco |
| `BRIDGE` | vmbr0 | Bridge de rede |

Para customizar:

```bash
bash /tmp/create-template.sh 9001 meu-template local-zfs vmbr0
```

### O que o script faz

1. **Download** da imagem Ubuntu 24.04 Cloud (~600MB, pré-instalada)
2. **Cria uma VM** com configuração otimizada (q35, UEFI, VirtIO, QEMU Guest Agent)
3. **Importa** a cloud image como disco principal
4. **Adiciona** drive cloud-init (para configuração na primeira boot)
5. **Converte** a VM em template (não pode ser ligada, apenas clonada)
6. **Cria role `TemplateCloneRole`** com `VM.Clone` + `VM.Audit` (se não existir)
7. **Concede ACL** nos grupos `researchers` e `students` em `/vms/<ID>` — sem isso, clonar dá 403
8. **Limpa** o arquivo temporário

## 2. Instalar os Snippets vendor-data (uma vez)

Os arquivos em `snippets/` contêm a configuração de pacotes que roda no primeiro boot de cada VM.

### Copie para o Proxmox

```bash
scp cloud-init/snippets/vendor-data-*.yaml root@192.168.10.134:/datapool/templates/snippets/
```

### Snippets disponíveis

| Arquivo | Uso | Conteúdo |
|---|---|---|
| `vendor-data-base.yaml` | VMs sem GPU | qemu-guest-agent + Docker Engine + Compose |
| `vendor-data-gpu.yaml` | VMs com GPU | Base + driver NVIDIA 590 + reboot automático |

### Referência no Terraform

No `.tfvars` do pesquisador:

```hcl
# VM sem GPU (padrão):
vendor_data_file_id = "datapool-templates:snippets/vendor-data-base.yaml"

# VM com GPU:
vendor_data_file_id = "datapool-templates:snippets/vendor-data-gpu.yaml"
```

## Usar com Terraform

Após criar o template e instalar os snippets, use o exemplo `terraform/examples/04-vm-cloud-init/`:

```bash
cd terraform/examples/04-vm-cloud-init/
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

terraform init
terraform apply
```

O pesquisador configura apenas: nome da VM, usuário, chave SSH e qual vendor-data usar.
**Nenhum acesso SSH ao host Proxmox** é necessário — tudo funciona via API.

## Estrutura

```
cloud-init/
├── create-template.sh                ← Script para criar template no Proxmox (admin)
├── snippets/
│   ├── vendor-data-base.yaml         ← Vendor-data: Docker + qemu-guest-agent
│   └── vendor-data-gpu.yaml          ← Vendor-data: Docker + NVIDIA driver 590
└── README.md                         ← Este arquivo
```
