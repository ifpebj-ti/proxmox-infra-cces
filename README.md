# Proxmox Infra — CCES/IFPE Belo Jardim

Repositório de infraestrutura do servidor Proxmox VE da **Coordenação de Curso de Engenharia de Software (CCES)** do IFPE Campus Belo Jardim.

## 📖 Documentação

A documentação completa de configuração do servidor está na **[Wiki deste repositório](../../wiki)**.

### Páginas da Wiki:

| Página | Conteúdo |
|---|---|
| [Home](../../wiki) | Índice geral |
| [01 — Hardware e BIOS](../../wiki/01-Hardware-e-BIOS) | Especificações do hardware e configurações da UEFI/BIOS |
| [02 — Instalação do Proxmox](../../wiki/02-Instalacao-Proxmox) | Instalação do Proxmox VE com ZFS RAID1 |
| [03 — Rede e Cluster](../../wiki/03-Rede-e-Cluster) | Configuração básica de rede pós-instalação |
| [04 — Storage](../../wiki/04-Storage) | Configuração de storage (ZFS, NVMe, SSD 20TB) |
| [05 — Backup](../../wiki/05-Backup) | Job de backup automático |
| [06 — Usuários, Grupos e Permissões](../../wiki/06-Usuarios-Grupos-Permissoes) | Realms, roles, ACLs, API tokens, TFA |
| [07 — GPU Passthrough](../../wiki/07-GPU-Passthrough) | Passthrough de GPUs, Resource Mappings, guia do pesquisador |
| [08 — NFS / Research Data](../../wiki/08-NFS-Research-Data) | Compartilhamento de dados de pesquisa via NFS |

## 📁 Estrutura do Repositório

```
proxmox-infra-cces/
├── README.md                    ← Este arquivo
├── LICENSE                      ← Apache License 2.0
├── terraform/                   ← (futuro) Módulos Terraform para provisionamento de VMs/CTs
├── ansible/                     ← (futuro) Playbooks Ansible para configuração automatizada
├── cloud-init/                  ← (futuro) Templates Cloud-Init para inicialização de VMs
└── self-service/                ← (futuro) Aplicação self-service para pesquisadores e alunos
```

## 🖥️ Hardware do Servidor

### pve01 — Servidor 1

| Componente | Especificação |
|---|---|
| Placa-mãe | ASUS TUF GAMING X670E-Plus |
| Processador | AMD Ryzen 9 7950X 16-Core |
| Memória RAM | 64 GB DDR5 (4x 16GB) |
| NVMe (Sistema) | 2x Samsung 990 Pro 4TB (RAID1 ZFS) |
| SSD (Dados) | 1x SSD 20TB |
| GPUs | 2x NVIDIA RTX 4060 (ZOTAC) — GPU Passthrough |

### pve02 — Servidor 2

| Componente | Especificação |
|---|---|
| Placa-mãe | MSI MPG X870E CARBON WIFI |
| Processador | AMD Ryzen 9 9950X 16-Core |
| Memória RAM | 128 GB DDR5 (4x 32GB) |
| NVMe (Sistema) | 2x Samsung 990 Pro 4TB (RAID1 ZFS) |
| SSD (Dados) | 1x SSD 20TB |
| GPUs | 2x NVIDIA GeForce RTX 5060 Ti |

## 👥 Equipe de Administração

| Nome | Função |
|---|---|
| Elton | Administrador |
| Hítalo | Administrador |
| Jailson | Administrador |

## 📝 Licença

Este projeto está licenciado sob a [Apache License 2.0](LICENSE).
