-- ============================================================
-- SOMA PARTNERS — Schema Supabase
-- Rodar no: Supabase Dashboard → SQL Editor → New query
-- ============================================================

-- CONCIERGE
CREATE TABLE IF NOT EXISTS concierge_clientes (
  id TEXT PRIMARY KEY,
  data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS concierge_pagamentos (
  id TEXT PRIMARY KEY,
  data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS concierge_tarefas (
  id TEXT PRIMARY KEY,
  data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS concierge_documentos (
  id TEXT PRIMARY KEY,
  data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS concierge_interacoes (
  id TEXT PRIMARY KEY,
  data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS concierge_lembretes (
  id TEXT PRIMARY KEY,
  data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- EVENTOS
CREATE TABLE IF NOT EXISTS eventos (
  id TEXT PRIMARY KEY,
  data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS eventos_convidados (
  id TEXT PRIMARY KEY,
  evento_id TEXT NOT NULL,
  data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- WEALTH
CREATE TABLE IF NOT EXISTS wealth_leads (
  id TEXT PRIMARY KEY,
  data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS wealth_followups (
  id TEXT PRIMARY KEY,
  lead_id TEXT NOT NULL,
  data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes para performance
CREATE INDEX IF NOT EXISTS idx_eventos_convidados_evento_id ON eventos_convidados(evento_id);
CREATE INDEX IF NOT EXISTS idx_wealth_followups_lead_id ON wealth_followups(lead_id);
