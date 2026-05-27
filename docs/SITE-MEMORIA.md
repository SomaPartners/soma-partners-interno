# Memória do Site Interno Soma Partners

## Stack
- **Frontend**: HTML/CSS/JS estático, sem framework
- **Deploy**: Vercel via GitHub auto-deploy (push → deploy automático)
- **Banco**: Supabase (anon key, RLS policies abertas para anon)
- **Repo**: https://github.com/SomaPartners/soma-partners-interno (branch `main`)

## Supabase
- URL: `https://mdftseanzfganeiyotlf.supabase.co`
- Anon Key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kZnRzZWFuemZnYW5laXlvdGxmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgyNTcwODgsImV4cCI6MjA5MzgzMzA4OH0.ZUD-vjmF0QX80U6EK4vJK7uek23NzCSTocxSGYH4PDo`

## Tabelas principais
| Tabela | Uso |
|---|---|
| `soma_usuarios` | Login da equipe (email, senha_hash SHA-256, is_admin) |
| `admin_lancamentos` | Lançamentos financeiros (receita/despesa) |
| `admin_extrato` | Extratos BTG importados |
| `admin_mkt_conteudo` | Calendário de marketing |
| `admin_ativos` | Ativos financeiros |
| `admin_avisos` | Avisos internos |
| `soma_clientes` | Clientes Concierge |
| `soma_followups` | Follow-ups de clientes |
| `wealth_leads` | Leads do CRM Wealth |
| `soma_eventos` | Eventos |

## Arquivos do site (todos críticos — devem estar no git)
```
admin.html          → Painel administrativo completo
admin-hash.html     → Login admin alternativo
calendario.html     → Calendário
cliente.html        → Ficha do cliente
concierge.html      → CRM Concierge
eventos.html        → Gestão de eventos
index.html          → Redirect para login.html
inscricao.html      → Inscrição
login.html          → *** CRÍTICO *** Login principal da equipe
manifest.json       → PWA manifest
relatorios.html     → Relatórios
soma-partners.html  → Hub principal (6 cards: Concierge, Wealth, Eventos, Soma Club, Soma News, Admin)
sw.js               → Service worker PWA
wealth.html         → CRM Wealth
schema.sql          → Schema do banco
icons/              → Ícones PWA (icon-120/152/180/192/512.png)
img/                → Imagens dos cards (concierge, wealth, eventos, somaclub, somanews, administrador)
```

## ⚠️ REGRA CRÍTICA — Git e Deploy
O Vercel só serve arquivos que estão **commitados no git**. Arquivos só na pasta local NÃO aparecem no site.

**Sempre que alterar qualquer arquivo**, usar o padrão de push:
```bash
REMOTE=$(git ls-remote origin refs/heads/main | awk '{print $1}')
IDX="/tmp/git-index-$$"
export GIT_INDEX_FILE=$IDX
git read-tree $REMOTE
git --work-tree="/sessions/.../mnt/SITE INTERNO SOMA" add <arquivos>
TREE=$(git write-tree)
COMMIT=$(git commit-tree $TREE -p $REMOTE -m "mensagem")
git push origin $COMMIT:refs/heads/main
```

**Se adicionar arquivo NOVO**, deve ser adicionado explicitamente no `git add` acima.

## Autenticação do site
- Login: `login.html` → busca `soma_usuarios` por email + senha_hash SHA-256
- Sessão: `sessionStorage` com keys `soma_auth='1'`, `soma_admin='1'`, `soma_nome`
- Guard em cada página: `if(sessionStorage.getItem('soma_auth')!=='1') window.location.href='login.html'`
- Admin guard: também checa `soma_admin==='1'`

## Módulo Extrato BTG (admin.html)

### 4 empresas
| Key | Nome | CNPJ |
|---|---|---|
| `soma` | Soma Partners Ltda | 63.898.584/0001-84 |
| `trai` | TR AI Ltda | 40.202.799/0001-13 |
| `wealth` | Soma Wealth Consultoria Ltda | 64.931.784/0001-54 |
| `trserv` | TR Serviços Financeiros Ltda | 36.617.889/0001-06 |

### Fluxo do extrato
1. Upload `.xlsx` BTG (header na linha 13, dados nas colunas índice 1=data, 2=descrição, 3=valor)
2. Auto-detecta empresa pelo CNPJ no arquivo
3. Categorização: só `interno` (transferências entre empresas) e `rendimento` (conta remunerada) — todo o resto é `nc`
4. Salvar → grava em `admin_extrato` + sincroniza não-internos para `admin_lancamentos`
5. Sync usa `tipo: valor>0 ? 'receita' : 'despesa'` (crítico para aparecer nos Lançamentos e DRE)
6. Entradas BTG em `admin_lancamentos` têm `obs` com prefixo `BTG·{empresa}|{mes}`

## Módulo Financeiro (admin.html)
- `admin_lancamentos`: campo `tipo` deve ser `'receita'` ou `'despesa'` (nunca `'entrada'`/`'saida'`)
- DRE: agrupa por mês, separa receitas e despesas, mostra resultado líquido
- Visão Financeira: usa `tipo==='receita'` e `tipo==='despesa'` para calcular totais

## Marketing (admin.html)
- Gerador automático de calendário por faixas de 30/60/90 dias
- Tipos de conteúdo: Educacional, Institucional, Produto/Serviço, Engajamento
- Calendário financeiro brasileiro: datas Copom 2026, prazo IR
