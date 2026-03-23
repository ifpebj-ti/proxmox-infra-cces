#!/usr/bin/env bash
# ============================================================================
# Cria template Ubuntu 24.04 Cloud no Proxmox
# Execute no host Proxmox (via SSH ou console root)
#
# Uso:
#   bash create-template.sh [TEMPLATE_ID] [TEMPLATE_NAME] [STORAGE] [BRIDGE]
#
# Exemplos:
#   bash create-template.sh                          # Padrões: ID 9000
#   bash create-template.sh 9001 ubuntu-2404-gpu     # ID e nome customizados
# ============================================================================

set -euo pipefail

# ── Parâmetros (ajuste via argumentos ou edite os padrões) ──
TEMPLATE_ID="${1:-9000}"
TEMPLATE_NAME="${2:-ubuntu-2404-cloud}"
STORAGE="${3:-local-zfs}"
BRIDGE="${4:-vmbr0}"

IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
IMAGE_FILE="/tmp/noble-server-cloudimg-amd64.img"

# Grupos que terão permissão de clonar o template (separados por espaço)
CLONE_GROUPS="researchers-external researchers-internal students"

# ── Help ──
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Uso: $0 [TEMPLATE_ID] [TEMPLATE_NAME] [STORAGE] [BRIDGE]"
  echo ""
  echo "Parâmetros (todos opcionais):"
  echo "  TEMPLATE_ID    ID do template no Proxmox   (padrão: 9000)"
  echo "  TEMPLATE_NAME  Nome do template             (padrão: ubuntu-2404-cloud)"
  echo "  STORAGE        Storage para discos           (padrão: local-zfs)"
  echo "  BRIDGE         Bridge de rede                (padrão: vmbr0)"
  echo ""
  echo "Exemplos:"
  echo "  $0                                    # Usa todos os padrões"
  echo "  $0 9001 ubuntu-2404-minimal           # ID 9001 com nome customizado"
  echo "  $0 9000 ubuntu-2404-cloud local-zfs vmbr1  # Todos os parâmetros"
  exit 0
fi

echo "═══════════════════════════════════════════════════════════════"
echo "  Criando template Ubuntu 24.04 Cloud"
echo "═══════════════════════════════════════════════════════════════"
echo "  ID:      ${TEMPLATE_ID}"
echo "  Nome:    ${TEMPLATE_NAME}"
echo "  Storage: ${STORAGE}"
echo "  Bridge:  ${BRIDGE}"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ── 1. Download da cloud image ──
if [ -f "${IMAGE_FILE}" ]; then
  echo ">> Imagem já existe em ${IMAGE_FILE}, pulando download..."
else
  echo ">> Baixando Ubuntu 24.04 Cloud Image (~600MB)..."
  wget -q --show-progress -O "${IMAGE_FILE}" "${IMAGE_URL}"
fi

# ── 2. Verificar se VM/template já existe ──
if qm status "${TEMPLATE_ID}" &>/dev/null; then
  echo ""
  echo "ERRO: VM/Template com ID ${TEMPLATE_ID} já existe!"
  echo "Para remover: qm destroy ${TEMPLATE_ID}"
  exit 1
fi

# ── 3. Criar VM base ──
echo ">> Criando VM base..."
qm create "${TEMPLATE_ID}" \
  --name "${TEMPLATE_NAME}" \
  --ostype l26 \
  --machine q35 \
  --bios ovmf \
  --cpu host \
  --cores 2 \
  --memory 2048 \
  --net0 "virtio,bridge=${BRIDGE}" \
  --scsihw virtio-scsi-single \
  --agent enabled=1 \
  --tags "cloud-template,ubuntu-2404"

# ── 4. Adicionar EFI disk ──
echo ">> Adicionando EFI disk..."
qm set "${TEMPLATE_ID}" --efidisk0 "${STORAGE}:1,efitype=4m"

# ── 5. Importar cloud image como disco ──
echo ">> Importando cloud image como disco (pode demorar)..."
qm set "${TEMPLATE_ID}" --scsi0 "${STORAGE}:0,import-from=${IMAGE_FILE},iothread=1,discard=on"

# ── 6. Adicionar drive cloud-init ──
echo ">> Adicionando drive cloud-init..."
qm set "${TEMPLATE_ID}" --ide2 "${STORAGE}:cloudinit"

# ── 7. Boot order ──
echo ">> Configurando boot order..."
qm set "${TEMPLATE_ID}" --boot order=scsi0

# ── 8. Serial console (útil para debug) ──
echo ">> Adicionando serial console..."
qm set "${TEMPLATE_ID}" --serial0 socket

# ── 9. Converter para template ──
echo ">> Convertendo para template..."
qm template "${TEMPLATE_ID}"

# ── 10. Criar role TemplateCloneRole (se não existir) ──
if pveum role list --output-format json 2>/dev/null | grep -q '"roleid":"TemplateCloneRole"'; then
  echo ">> Role TemplateCloneRole já existe, pulando..."
else
  echo ">> Criando role TemplateCloneRole (VM.Clone + VM.Audit)..."
  pveum role add TemplateCloneRole --privs "VM.Clone VM.Audit"
fi

# ── 11. Conceder permissão de clone aos grupos ──
for group in ${CLONE_GROUPS}; do
  echo ">> Concedendo TemplateCloneRole ao grupo '${group}' em /vms/${TEMPLATE_ID}..."
  pveum acl modify "/vms/${TEMPLATE_ID}" --roles TemplateCloneRole --groups "${group}"
done

# ── 12. Limpar imagem temporária ──
echo ">> Limpando arquivo temporário..."
rm -f "${IMAGE_FILE}"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  ✓ Template criado com sucesso!"
echo "═══════════════════════════════════════════════════════════════"
echo "  ID:     ${TEMPLATE_ID}"
echo "  Nome:   ${TEMPLATE_NAME}"
echo "  Tags:   cloud-template, ubuntu-2404"
echo "  ACL:    TemplateCloneRole → ${CLONE_GROUPS}"
echo ""
echo "  No Terraform, use:"
echo "    template_name = \"${TEMPLATE_NAME}\""
echo "═══════════════════════════════════════════════════════════════"
