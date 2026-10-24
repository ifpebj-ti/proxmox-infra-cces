# 05 — VM Ubuntu Cloud-Init entre nós do cluster

Cria uma VM no **pve02** a partir do template Cloud-Init `ubuntu-2404-cloud` (ID `9000`) que já existe no **pve01**. O provider clona o template na origem e migra seus discos para o storage de destino `local-zfs` do pve02. Cloud-init configura usuário, chave SSH, Docker, QEMU Guest Agent e, usando o snippet GPU, o driver NVIDIA.

Este é um projeto Terraform independente do exemplo 04, com state local próprio neste diretório. Não copie state ou `terraform.tfvars` entre os exemplos.

## Arquivos

```text
05-vm-cloud-init-cluster/
├── .gitignore
├── .terraform.lock.hcl         # Versão e checksums do provider
├── README.md
├── main.tf                    # Provider Proxmox
├── variables.tf               # Variáveis do template, destino e VM
├── vm.tf                      # Clone cross-node, cloud-init, GPU e outputs
└── terraform.tfvars.example   # Exemplo sem credenciais reais
```

O arquivo `terraform.tfvars` real, os arquivos `terraform.tfstate*` e o diretório `.terraform/` são locais e não são distribuídos com este projeto. Preencha um arquivo de variáveis novo neste diretório usando um token válido e recém-rotacionado.

## Pré-requisitos no Proxmox

1. O template `9000` (`ubuntu-2404-cloud`) precisa existir no pve01, usar Cloud-Init/UEFI e ter seus discos em `local-zfs`.
2. `local-zfs` precisa estar disponível no pve02 e ter espaço para o clone e o disco configurado para a VM.
3. O storage local `datapool-templates-pve02` precisa estar ativo no pve02 com conteúdo `snippets`, e o arquivo `vendor-data-gpu.yaml` precisa existir em `/datapool/templates-pve02/snippets/`.
4. O mapping `gpu-rtx5060ti-pve02-01` precisa existir no cluster e apontar para a primeira RTX 5060 Ti do pve02. O token precisa ter permissão para usar o mapping.
5. O usuário/token do Terraform precisa poder clonar o template no pve01, criar/configurar a VM no pve02, alocar os discos no `local-zfs` de destino e atribuir a VM ao pool `researchers`. Confirme as permissões efetivas para operações de clone entre nós e de GPU passthrough antes do apply.
6. A chave pública indicada por `ssh_public_key_file` precisa existir na máquina onde Terraform será executado.

O provider `bpg/proxmox` aceita `clone.node_name` para selecionar o nó de origem e `clone.datastore_id` para indicar o storage de destino. O exemplo usa esses argumentos explicitamente, pois o template é local ao pve01 e a VM será criada no pve02.

## Snippet e dados de pesquisa

O `terraform.tfvars.example` seleciona:

```hcl
vendor_data_file_id = "datapool-templates-pve02:snippets/vendor-data-gpu.yaml"
```

O snippet `cloud-init/snippets/vendor-data-gpu.yaml` instala `nvidia-driver-595-open`. A RTX 5060 Ti exige o módulo open; o módulo proprietário falhou ao inicializar a GPU. Como `vendor_data_file_id` referencia o snippet armazenado localmente no pve02, copie a versão atualizada para `/datapool/templates-pve02/snippets/vendor-data-gpu.yaml` antes de criar outras VMs. O snippet também configura a montagem NFS `172.26.3.10:/datapool/research-data`; assim, a VM no pve02 precisa alcançar o compartilhamento exportado pelo pve01. Ele **não** monta o dataset local independente `datapool/research-data-pve02`; para usar esses dados, prepare um snippet apropriado para essa topologia.

## Configurar e validar

```bash
cd terraform/examples/05-vm-cloud-init-cluster/
cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars
terraform init
terraform validate
terraform plan
```

Revise o plano antes de aplicar. Confirme que ele cria uma nova VM em `pve02`, usa `9000` como template de origem em `pve01`, direciona os discos a `local-zfs`, usa o snippet local do pve02 e configura o mapping GPU esperado. Não execute `terraform apply` até esses pontos e as permissões estarem confirmados.

Valores importantes do exemplo:

| Variável | Valor usado | Observação |
|---|---|---|
| `template_id` | `9000` | ID do template de origem |
| `template_node` | `pve01` | Nó onde o template existe |
| `proxmox_node` | `pve02` | Nó de destino da VM |
| `clone_datastore_id` | `local-zfs` | Storage de destino dos discos clonados |
| `vm_memory` | `65536` | Memória em MB, equivalente a 64 GiB; deve ser inteiro |
| `vendor_data_file_id` | `datapool-templates-pve02:snippets/vendor-data-gpu.yaml` | Snippet local ao pve02 |
| `gpu_mapping` | `gpu-rtx5060ti-pve02-01` | Primeira RTX 5060 Ti do pve02 |

Para usar a segunda GPU, altere `gpu_mapping` para `gpu-rtx5060ti-pve02-02`. A VM e o mapping permanecem associados ao pve02; não são candidatos a failover para o pve01.

## Depois do apply

O snippet GPU reinicia a VM ao terminar a instalação do driver. Aguarde o QEMU Guest Agent voltar, então consulte:

```bash
terraform output ssh_command
```

Dentro da VM, valide o driver com:

```bash
nvidia-smi
```

A saída do `nvidia-smi` deve listar a RTX 5060 Ti passada à VM.
