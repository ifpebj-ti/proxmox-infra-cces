# Exemplos Terraform — Proxmox CCES/IFPE

Exemplos de provisionamento de VMs no Proxmox via Terraform, organizados por complexidade.

## Estrutura

```
terraform/examples/
├── 00-vm-api-teste/            ← Teste mínimo de API + permissões
│   ├── main.tf                 ← Provider (terraform{} + provider{})
│   ├── variables.tf            ← Variáveis
│   └── test-vm.tf              ← VM mínima (ID 9999)
│
├── 01-vm-ubuntu-iso/           ← VM Ubuntu com ISO (instalação manual)
│   ├── main.tf                 ← Provider
│   ├── variables.tf            ← Variáveis
│   └── vm.tf                   ← Recurso da VM + outputs
│
├── 02-vm-ansible/              ← VM Ubuntu + Ansible (QEMU Guest Agent + Docker)
│   ├── main.tf                 ← Provider
│   ├── variables.tf            ← Variáveis
│   ├── vm.tf                   ← Recurso da VM + outputs
│   └── ansible.tf              ← Provisionamento via Ansible
│
├── 03-vm-gpu-ansible/          ← VM Ubuntu + GPU RTX 4060 + Ansible
│   ├── main.tf                 ← Provider
│   ├── variables.tf            ← Variáveis
│   ├── vm.tf                   ← Recurso da VM com GPU + outputs
│   └── ansible.tf              ← Provisionamento via Ansible
│
└── 04-vm-cloud-init/           ← VM automatizada com cloud-init (sem instalar SO)
    ├── main.tf                 ← Provider
    ├── variables.tf            ← Variáveis
    ├── vm.tf                   ← Template lookup + VM clone + cloud-init + outputs
    └── cloud-config.yaml.tftpl ← Template cloud-config (user, Docker, NVIDIA)

cloud-init/
├── create-template.sh          ← Script para criar template no Proxmox (executar 1x)
└── README.md

ansible/
└── playbooks/
    └── setup-vm.yml            ← Playbook compartilhado (usado pelos exemplos 02 e 03)
```

> **Padrão modular:** Em todos os exemplos, `main.tf` contém **apenas** a configuração do provider.
> Os recursos ficam em arquivos separados (`vm.tf`, `ansible.tf`, `test-vm.tf`) para facilitar leitura e manutenção.

## Exemplos

| # | Exemplo | Descrição | Arquivos | Pool |
|---|---|---|---|---|
| 00 | [Teste de API](00-vm-api-teste/) | VM mínima para validar API + permissões | `main.tf` `test-vm.tf` `variables.tf` | researchers / students |
| 01 | [VM Ubuntu ISO](01-vm-ubuntu-iso/) | VM otimizada com ISO montada, instalação manual do SO | `main.tf` `vm.tf` `variables.tf` | researchers / students |
| 02 | [VM + Ansible](02-vm-ansible/) | VM + provisionamento automático (QEMU Guest Agent + Docker) | `main.tf` `vm.tf` `ansible.tf` `variables.tf` | researchers / students |
| 03 | [VM + GPU + Ansible](03-vm-gpu-ansible/) | VM com GPU RTX 4060 passthrough + Ansible | `main.tf` `vm.tf` `ansible.tf` `variables.tf` | researchers **apenas** |
| 04 | [VM Cloud-Init](04-vm-cloud-init/) | **Deploy automatizado** — sem instalar SO, com Docker + NVIDIA | `main.tf` `vm.tf` `cloud-config.yaml.tftpl` `variables.tf` | researchers / students |

## Como usar cada exemplo

Cada exemplo é um projeto Terraform independente. Entre na pasta, copie o `.tfvars.example`, preencha e execute:

```bash
cd terraform/examples/<exemplo>/
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

terraform init
terraform plan
terraform apply
```

## Tokens compatíveis

| Token | 00 (Teste) | 01 (ISO) | 02 (Ansible) | 03 (GPU) | 04 (Cloud-Init) |
|---|---|---|---|---|---|
| `elton@pam!terraform` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `terraform-research@pve!terraform` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `terraform-students@pve!terraform` | ✅ | ✅ | ✅ | ❌ (sem acesso a GPU) | ✅ |
| Token pessoal de pesquisador | ✅ | ✅ | ✅ | ✅ | ✅ |
| Token pessoal de aluno | ✅ | ✅ | ✅ | ❌ (sem acesso a GPU) | ✅ |
