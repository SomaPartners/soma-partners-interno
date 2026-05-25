# Soma Partners — Supabase Integration + Wealth Module
**Date:** 2026-05-04

## Overview

Migrate Concierge and Eventos modules from localStorage to Supabase, integrate inscricao.html with the same backend, and build the new Wealth module (commercial CRM with kanban pipeline).

## Architecture

- **Hosting:** GitHub Pages (static HTML)
- **Backend:** Supabase (PostgreSQL + JS client via CDN)
- **Auth:** None — shared database, anon key embedded in HTML, RLS disabled
- **Pattern:** Replace `loadData()`/`saveData()` with async/await Supabase calls. UI shows loading state. Errors show a non-blocking toast.

## Files Affected

| File | Change |
|------|--------|
| `concierge.html` | Replace data layer with Supabase |
| `eventos.html` | Replace data layer with Supabase |
| `inscricao.html` | Replace localStorage write with Supabase insert |
| `soma-partners.html` | Link Wealth card to `wealth.html` |
| `wealth.html` | New file |

## Database Schema

### Concierge Tables

```sql
CREATE TABLE concierge_clientes (
  id TEXT PRIMARY KEY,
  nome TEXT NOT NULL,
  email TEXT,
  telefone TEXT,
  cpf TEXT,
  perfil TEXT,
  status TEXT DEFAULT 'ativo',
  patrimonio TEXT,
  objetivo TEXT,
  origem TEXT,
  responsavel TEXT,
  obs TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE concierge_pagamentos (
  id TEXT PRIMARY KEY,
  cliente_id TEXT REFERENCES concierge_clientes(id) ON DELETE CASCADE,
  descricao TEXT NOT NULL,
  valor NUMERIC,
  vencimento DATE,
  status TEXT DEFAULT 'pendente',
  tipo TEXT,
  obs TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE concierge_tarefas (
  id TEXT PRIMARY KEY,
  cliente_id TEXT REFERENCES concierge_clientes(id) ON DELETE SET NULL,
  titulo TEXT NOT NULL,
  prioridade TEXT DEFAULT 'media',
  status TEXT DEFAULT 'aberta',
  responsavel TEXT,
  prazo DATE,
  obs TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE concierge_documentos (
  id TEXT PRIMARY KEY,
  cliente_id TEXT REFERENCES concierge_clientes(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  tipo TEXT,
  tamanho TEXT,
  url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE concierge_interacoes (
  id TEXT PRIMARY KEY,
  cliente_id TEXT REFERENCES concierge_clientes(id) ON DELETE CASCADE,
  tipo TEXT,
  descricao TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE concierge_lembretes (
  id TEXT PRIMARY KEY,
  cliente_id TEXT REFERENCES concierge_clientes(id) ON DELETE SET NULL,
  titulo TEXT NOT NULL,
  data DATE,
  prioridade TEXT DEFAULT 'media',
  status TEXT DEFAULT 'pendente',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Eventos Tables

```sql
CREATE TABLE eventos (
  id TEXT PRIMARY KEY,
  nome TEXT NOT NULL,
  data DATE,
  horario TEXT,
  local TEXT,
  objetivo TEXT,
  publico TEXT,
  status TEXT DEFAULT 'planejamento',
  descricao TEXT,
  inscricao TEXT,
  credenciamento TEXT,
  checklist JSONB DEFAULT '[]',
  cronograma JSONB DEFAULT '[]',
  patrocinios JSONB DEFAULT '[]',
  equipe JSONB DEFAULT '[]',
  compras JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE eventos_convidados (
  id TEXT PRIMARY KEY,
  evento_id TEXT REFERENCES eventos(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  email TEXT,
  telefone TEXT,
  empresa TEXT,
  rsvp TEXT DEFAULT 'pendente',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Wealth Tables

```sql
CREATE TABLE wealth_leads (
  id TEXT PRIMARY KEY,
  nome TEXT NOT NULL,
  telefone TEXT,
  patrimonio_estimado TEXT,
  origem TEXT,
  responsavel TEXT,
  estagio TEXT DEFAULT 'prospeccao',
  temperatura TEXT DEFAULT 'frio',
  obs TEXT,
  proxima_acao TEXT,
  data_proxima_acao DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE wealth_followups (
  id TEXT PRIMARY KEY,
  lead_id TEXT REFERENCES wealth_leads(id) ON DELETE CASCADE,
  descricao TEXT NOT NULL,
  tipo TEXT,
  data_prevista DATE,
  data_realizada DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Wealth Module Design

### Visual
Identical to `concierge.html`: dark sidebar (`#0f172a`), light content (`#f1f5f9`), Montserrat font, inline SVG icons, no emojis.

### Sidebar Sections
- Visão Geral (KPI dashboard)
- Pipeline (kanban)
- Follow-ups
- Leads (tabular list)

### Pipeline
- 5 columns: Prospecção / Qualificação / Reunião / Proposta / Fechado · Perdido
- Card fields: nome, patrimônio estimado, temperatura badge, responsável, data próxima ação
- Overdue alert: red left-border + clock icon when `data_proxima_acao < today`
- Warning alert: yellow background when due within 2 days
- Move between stages: "Mover para →" button on card (no drag-and-drop)

### Follow-ups Tab
- Shows all overdue + today's follow-ups, sorted by urgency (overdue first, then by date)
- Each item: lead name, action description, due date, status badge
- "Marcar como feito" button: records `data_realizada`, opens modal to schedule next follow-up

### KPIs (Visão Geral)
- Total leads ativos
- Leads quentes
- Follow-ups vencidos
- Patrimônio total em pipeline

## Implementation Order

1. Push `eventos.html` (URL fix already staged)
2. Apply Supabase schema (SQL — user runs in Supabase dashboard)
3. Integrate Supabase in `concierge.html`
4. Integrate Supabase in `eventos.html` + `inscricao.html`
5. Build `wealth.html`
6. Update `soma-partners.html` (Wealth card link)
7. Final push to GitHub
