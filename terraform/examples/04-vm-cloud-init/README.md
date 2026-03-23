# 04 — VM Ubuntu Cloud-Init (deploy automatizado)

Cria uma VM Ubuntu em **segundos**, sem instalação manual do SO.
Usa cloud-init para configurar automaticamente: usuário, SSH, Docker, QEMU Guest Agent e (opcionalmente) driver NVIDIA.

## Comparação com exemplos anteriores

| Aspecto | Exemplos 01-03 (ISO) | Exemplo 04 (Cloud-Init) |
|---|---|---|
| Imagem | ISO ~2GB + instalação manual | Cloud image ~600MB, pré-instalada |
| Tempo de deploy | 20-40 min | **~2 minutos** |
| Configuração de usuário | Manual no instalador | Automático via cloud-init |
| Chave SSH | Manual (`ssh-copy-id`) | Injetada automaticamente |
| Sudo sem senha | Configurar manualmente | Já vem configurado |
| Docker | Ansible (etapa separada) | Instalado no primeiro boot |
| Etapas | 2 etapas (criar + provisionar) | **1 etapa** |

## Arquitetura (Admin vs Pesquisador)

Este exemplo separa a responsabilidade em duas camadas:

| Etapa | Quem faz | O que faz | Frequência |
|---|---|---|---|
| **1. Template** | Admin | Cria template `ubuntu-2404-cloud` via `create-template.sh` | Uma vez |
| **2. Snippets** | Admin | Copia `vendor-data-*.yaml` para o storage do Proxmox | Uma vez |
| **3. VM** | Pesquisador | `terraform apply` com suas variáveis (usuário, chave SSH) | Cada VM |

O pesquisador **não precisa de acesso SSH ao host Proxmox** — tudo funciona via API.

## Pré-requisitos

### 1. Template criado no Proxmox (admin)

Execute o script **uma única vez** no host Proxmox:

```bash
# Do admin, envie o script:
scp cloud-init/create-template.sh root@192.168.10.134:/tmp/

# No Proxmox, execute:
ssh root@192.168.10.134 "bash /tmp/create-template.sh"
```

### 2. Snippets copiados para o Proxmox (admin)

Os vendor-data ficam em `cloud-init/snippets/`. Copie para o host:

```bash
scp cloud-init/snippets/vendor-data-*.yaml root@192.168.10.134:/datapool/templates/snippets/
```

Isso disponibiliza os snippets no storage `datapool-templates`.

Veja [cloud-init/README.md](../../../cloud-init/README.md) para detalhes.

### 3. Chave SSH (pesquisador)

O pesquisador precisa ter um par de chaves SSH:

```bash
# Se ainda não tem:
ssh-keygen -t rsa -b 4096
```

## Como usar

```bash
cd terraform/examples/04-vm-cloud-init/

# 1. Configurar variáveis
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 2. Criar a VM (tudo automático!)
terraform init
terraform apply
```

Pronto! Após ~2 minutos, a VM estará rodando com:
- ✅ Ubuntu 24.04 instalado
- ✅ Usuário configurado com sua chave SSH
- ✅ Sudo sem senha
- ✅ QEMU Guest Agent ativo
- ✅ Docker Engine + Compose instalados
- ✅ Driver NVIDIA (se usar `vendor-data-gpu.yaml`)

### Acessar a VM

```bash
# O IP aparece no output do Terraform (após o QEMU Guest Agent iniciar):
terraform output ssh_command

# Ou conecte diretamente:
ssh pesquisador@<IP>
```

## Variáveis importantes

| Variável | Descrição | Padrão |
|---|---|---|
| `template_id` | ID do template (mais confiável) | `0` (busca por nome) |
| `template_name` | Nome do template cloud-init | `ubuntu-2404-cloud` |
| `vm_name` | Nome da VM | `ubuntu-cloud` |
| `vm_user` | Usuário criado na VM | `ubuntu` |
| `ssh_public_key_file` | Caminho da chave pública | `~/.ssh/id_rsa.pub` |
| `vendor_data_file_id` | Snippet vendor-data no Proxmox | `datapool-templates:snippets/vendor-data-base.yaml` |
| `gpu_mapping` | Resource Mapping da GPU | `""` (sem GPU) |

## GPU + NVIDIA

Para VMs com GPU passthrough, configure no `.tfvars`:

```hcl
gpu_mapping           = "gpu-rtx4060-01"
vendor_data_file_id   = "datapool-templates:snippets/vendor-data-gpu.yaml"
```

O vendor-data GPU instala o driver NVIDIA 590, o que pode demorar um pouco, e **reinicia a VM automaticamente** para que o módulo carregue. Logo, sua sessão do shell será reiniciada. Após o reboot, verifique:

```bash
ssh pesquisador@<IP>
nvidia-smi
```

> **Nota**: GPU passthrough precisa estar configurado no Proxmox (IOMMU, Resource Mapping).
> Apenas o pool `researchers` tem acesso às GPUs.

## Estrutura dos arquivos

```
04-vm-cloud-init/
├── main.tf                      ← Provider (terraform{} + provider{})
├── vm.tf                        ← Template lookup + VM clone + cloud-init + outputs
├── variables.tf                 ← Todas as variáveis
├── terraform.tfvars.example     ← Exemplo de valores
└── .gitignore
```

## Como funciona internamente

1. **Terraform busca o template** por ID ou nome (dinâmico)
2. **Clona o template** → VM nova em segundos
3. **Cloud-init executa** na primeira boot com dois data sources:
   - **user_account** (via API Proxmox): cria usuário + SSH key + sudo
   - **vendor-data** (snippet pré-existente): instala Docker, qemu-guest-agent, (NVIDIA)
4. **VM pronta** para uso via SSH

## Para destruir

```bash
terraform destroy
```
