# 01 — VM Ubuntu Server (instalação via ISO)

Cria uma VM otimizada no Proxmox com a ISO do Ubuntu Server montada, pronta para instalação manual.

## Características da VM

| Configuração | Valor |
|---|---|
| Machine | q35 (moderno, suporta PCIe passthrough) |
| BIOS | OVMF (UEFI) |
| SCSI | VirtIO SCSI Single (alta performance + iothread) |
| CPU Type | host (expõe instruções reais do processador) |
| QEMU Guest Agent | Habilitado |
| Disco | local-zfs (NVMe RAID1) com discard/TRIM |
| Rede | VirtIO no bridge vmbr0 |

## Uso

```bash
cd terraform/examples/01-vm-ubuntu-iso/

# 1. Configurar variáveis
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 2. Inicializar e aplicar
terraform init
terraform plan
terraform apply
```

## Após o `apply`

1. Acesse o console da VM no Proxmox (noVNC)
2. A ISO do Ubuntu Server será iniciada automaticamente
3. Siga o instalador normalmente
4. Após a instalação, instale o QEMU Guest Agent dentro da VM:

```bash
sudo apt install qemu-guest-agent -y
sudo systemctl enable --now qemu-guest-agent
```

## Para destruir

```bash
terraform destroy
```
