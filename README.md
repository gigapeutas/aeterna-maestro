# Æ Aeterna.ia — Maestro

> **O Orquestrador do Agente Econômico Autônomo (AEA)**
> Stack: n8n · Render Free Tier · Supabase PostgreSQL

---

## O que é o Maestro?

O **Maestro** é o núcleo de orquestração da Aeterna.ia. Ele não executa tarefas — ele **divide, delega, valida e memoriza**. Operando sobre o n8n Open Source, o Maestro é responsável por:

- Rotear tarefas entre os **Agentes Especialistas** (Groq/Llama-3 e Gemini)
- Acionar o **Sandbox de Validação** (GitHub Actions) para testar lógicas antes de memorizá-las
- Gravar conhecimento validado no **Dataset Dourado** (Supabase)
- Executar micro-decisões financeiras via módulo **FinOps** (Stripe)

---

## Infraestrutura: O Bypass de Custo Zero

A arquitetura foi projetada para operar com **custo de infraestrutura zero** na fase de Simbiose, usando três pilares gratuitos encadeados:

```
[Render Free Tier]          [Supabase]              [Groq / Gemini]
  n8n Orquestrador   ──►   PostgreSQL (memória)  ◄──  Pool de 25 chaves
  512MB RAM               Dataset Dourado             Llama-3 + Gemini
  Porta 10000             Credenciais cifradas        Balanceamento de carga
```

### Por que Render?
- Deploy via Docker direto do repositório GitHub — **zero configuração de servidor**
- Free Tier comporta o n8n dentro do limite de 512MB RAM (configurado para usar no máximo 460MB via `NODE_OPTIONS`)
- Disco efêmero não é problema: **todo o estado é persistido no Supabase**, não no container

### Por que Supabase?
- PostgreSQL gerenciado com **SSL nativo** e **free tier generoso** (500MB, sem limite de linhas)
- Funciona como a "memória de longo prazo" do Agente — workflows, credenciais e o Dataset Dourado vivem aqui
- API REST automática permite que outros módulos da Aeterna leiam/escrevam sem passar pelo n8n

---

## Estrutura do Repositório

```
maestro/
├── Dockerfile          # Imagem n8n configurada para Render
├── render.yaml         # Blueprint de deploy automático
├── .env.example        # Template de variáveis (NÃO commitar .env)
├── .gitignore          # Protege segredos e node_modules
└── README.md           # Este arquivo
```

---

## Deploy em 5 Passos (via Smartphone)

### Pré-requisitos
- Conta no [GitHub](https://github.com) (repositório criado)
- Conta no [Render](https://render.com) (gratuita)
- Conta no [Supabase](https://supabase.com) (projeto criado)

---

### Passo 1 — Subir o repositório no GitHub

Pelo app do GitHub (iOS/Android) ou pelo navegador mobile:

1. Crie um repositório chamado `maestro` (privado recomendado)
2. Faça upload dos 4 arquivos: `Dockerfile`, `render.yaml`, `.env.example`, `README.md`
3. Adicione também um `.gitignore` com `.env` na primeira linha

---

### Passo 2 — Pegar as credenciais do Supabase

No painel do Supabase, acesse:
**Project Settings → Database → Connection parameters**

Anote:
| Campo | Onde encontrar |
|---|---|
| `DB_POSTGRESDB_HOST` | Host (ex: `db.xxxx.supabase.co`) |
| `DB_POSTGRESDB_PORT` | Port (`5432`) |
| `DB_POSTGRESDB_DATABASE` | Database Name (`postgres`) |
| `DB_POSTGRESDB_USER` | User (`postgres`) |
| `DB_POSTGRESDB_PASSWORD` | Database Password |

---

### Passo 3 — Criar o serviço no Render

1. Acesse [render.com](https://render.com) → **New → Web Service**
2. Conecte sua conta GitHub e selecione o repositório `maestro`
3. Render detectará o `Dockerfile` automaticamente
4. Selecione **Free** como plano
5. **Não clique em Deploy ainda**

---

### Passo 4 — Injetar as variáveis de ambiente no Render

Na tela de criação do serviço, clique em **Environment** e adicione **uma a uma** as variáveis do `.env.example`, com os valores reais do Supabase.

Variáveis obrigatórias para o primeiro boot:

```
DB_TYPE                              = postgresdb
DB_POSTGRESDB_HOST                   = db.xxxx.supabase.co
DB_POSTGRESDB_PORT                   = 5432
DB_POSTGRESDB_DATABASE               = postgres
DB_POSTGRESDB_USER                   = postgres
DB_POSTGRESDB_PASSWORD               = [sua senha]
DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED = false
N8N_BASIC_AUTH_ACTIVE                = true
N8N_BASIC_AUTH_USER                  = admin
N8N_BASIC_AUTH_PASSWORD              = [senha forte]
N8N_ENCRYPTION_KEY                   = [string aleatória 32+ chars]
WEBHOOK_URL                          = https://[seu-app].onrender.com/
```

> **Dica mobile:** Gere a `N8N_ENCRYPTION_KEY` acessando
> `https://www.uuidgenerator.net/` e concatenando dois UUIDs.

---

### Passo 5 — Deploy

Clique em **Create Web Service**. O Render irá:

1. Clonar o repositório
2. Fazer build da imagem Docker
3. Subir o container na porta `10000`
4. Disponibilizar o n8n em `https://[seu-app].onrender.com`

O primeiro boot leva **~3 minutos**. Acesse a URL, autentique com
`N8N_BASIC_AUTH_USER` / `N8N_BASIC_AUTH_PASSWORD` e o Maestro estará operacional.

---

## Pool de APIs — Bypass de Rate Limit

O Maestro opera com **25 chaves de API gratuitas** em balanceamento de carga:

| Provider | Instâncias | Uso |
|---|---|---|
| **Groq (Llama-3)** | 15 projetos | Reflexos rápidos, baixa latência |
| **Gemini** | 10 chaves | Contexto longo, raciocínio profundo |

No n8n, configure um **Switch Node** com lógica Round-Robin ou baseada em erro HTTP 429 (rate limit) para rotacionar automaticamente entre as chaves. Armazene as chaves como **Credentials** cifradas no Supabase.

---

## Variáveis de Ambiente — Referência Completa

| Variável | Obrigatória | Descrição |
|---|---|---|
| `DB_TYPE` | ✅ | Tipo de banco (`postgresdb`) |
| `DB_POSTGRESDB_HOST` | ✅ | Host do Supabase |
| `DB_POSTGRESDB_PORT` | ✅ | Porta PostgreSQL (`5432`) |
| `DB_POSTGRESDB_DATABASE` | ✅ | Nome do banco (`postgres`) |
| `DB_POSTGRESDB_USER` | ✅ | Usuário do banco |
| `DB_POSTGRESDB_PASSWORD` | ✅ | Senha do banco |
| `DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED` | ✅ | `false` para Supabase |
| `N8N_BASIC_AUTH_ACTIVE` | ✅ | Habilita login no painel |
| `N8N_BASIC_AUTH_USER` | ✅ | Usuário do painel n8n |
| `N8N_BASIC_AUTH_PASSWORD` | ✅ | Senha do painel n8n |
| `N8N_ENCRYPTION_KEY` | ✅ | Chave de criptografia das credenciais |
| `WEBHOOK_URL` | ✅ | URL pública do Render |
| `NODE_OPTIONS` | ✅ | `--max-old-space-size=460` |
| `N8N_PORT` | ✅ | `10000` |
| `PORT` | ✅ | `10000` |

---

## Limitações do Free Tier e Mitigações

| Limitação | Impacto | Mitigação |
|---|---|---|
| **Render dorme após 15min de inatividade** | Cold start de ~30s | Usar UptimeRobot (gratuito) para ping a cada 10min |
| **Disco efêmero** | Dados locais perdidos no restart | Toda persistência via Supabase (já implementado) |
| **512MB RAM** | OOM Kill em workflows pesados | `NODE_OPTIONS=--max-old-space-size=460` já configurado |
| **Supabase pausa após 7 dias sem uso** | Banco offline | Manter um workflow n8n de heartbeat agendado |

---

## Próximos Passos

- [ ] Criar o primeiro workflow: **Agente de Roteamento** (recebe tarefa → decide Groq ou Gemini)
- [ ] Configurar **UptimeRobot** para manter o Render acordado
- [ ] Criar tabela `golden_dataset` no Supabase para armazenar lógicas validadas
- [ ] Implementar o **Sandbox Trigger** (webhook → GitHub Actions → resultado)
- [ ] Ativar o módulo **FinOps** (Stripe Issuing → cartão corporativo da IA)

---

## Segurança

- **Nunca** commite `.env` no Git
- Rotacione a `N8N_ENCRYPTION_KEY` apenas se migrar de instância (invalida credenciais antigas)
- Use o **Render Secret Files** para variáveis críticas em produção
- Habilite 2FA na conta Render e Supabase

---

*© 2025 Aeterna.ia — Construindo soberania, uma iteração por vez.*
