# Proxmox Infra — CCES/IFPE Belo Jardim

Repositório de infraestrutura do servidor Proxmox VE do **Centro de Ciências Exatas e Sociais (CCES)** do IFPE Campus Belo Jardim.

## 📖 Documentação

A documentação completa de configuração do servidor está na **[Wiki deste repositório](../../wiki)**.

### Páginas da Wiki:

| Página | Conteúdo |
|---|---|
| [Home](../../wiki) | Índice geral |
| [01 — Hardware e BIOS](../../wiki/01-Hardware-e-BIOS) | Especificações do hardware e configurações da UEFI/BIOS |
| [02 — Instalação do Proxmox](../../wiki/02-Instalacao-Proxmox) | Instalação do Proxmox VE com ZFS RAID1 |
| [03 — Storage](../../wiki/03-Storage) | Configuração de storage (ZFS, NVMe, SSD 20TB) |
| [04 — Backup](../../wiki/04-Backup) | Job de backup automático |
| [05 — Usuários, Grupos e Permissões](../../wiki/05-Usuarios-Grupos-Permissoes) | Realms, roles, ACLs, API tokens, TFA |
| [06 — GPU Passthrough](../../wiki/06-GPU-Passthrough) | Passthrough das 2x RTX 4060, Resource Mappings, guia do pesquisador |
| [07 — NFS / Research Data](../../wiki/07-NFS-Research-Data) | Compartilhamento de dados de pesquisa via NFS |

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

| Componente | Especificação |
|---|---|
| Placa-mãe | ASUS TUF GAMING X670E-Plus |
| Processador | AMD Ryzen 9 |
| Memória RAM | 64 GB DDR5 (4x 16GB) |
| NVMe (Sistema) | 2x Samsung 990 Pro 4TB (RAID1 ZFS) |
| SSD (Dados) | 1x SSD 20TB |
| GPUs | 2x NVIDIA RTX 4060 (ZOTAC) — GPU Passthrough |

## 👥 Equipe de Administração

| Nome | Função |
|---|---|
| Elton | Administrador |
| Hítalo | Administrador |
| Jailson | Administrador |

## 📝 Licença

Este projeto está licenciado sob a [Apache License 2.0](LICENSE).