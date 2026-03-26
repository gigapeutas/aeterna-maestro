# ─── Aeterna.ia — Maestro Orquestrador ───────────────────────────────────────
# Base: imagem oficial n8n (Alpine Linux, Node 18)
FROM n8nio/n8n:latest

# ─── Evitar OOM Kill no Render Free Tier (512MB RAM) ─────────────────────────
ENV NODE_OPTIONS="--max-old-space-size=460"

# ─── Porta obrigatória do Render Free Tier ────────────────────────────────────
ENV PORT=10000
ENV N8N_PORT=10000

# ─── Desabilitar checagem de permissões (necessário em disco efêmero) ─────────
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false

# ─── Expor a porta para o Render detectar automaticamente ─────────────────────
EXPOSE 10000

# ─── Iniciar o orquestrador ───────────────────────────────────────────────────
CMD ["n8n", "start"]
