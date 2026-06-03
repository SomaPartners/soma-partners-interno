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

-- ADMIN
CREATE TABLE IF NOT EXISTS admin_lancamentos (
  id TEXT PRIMARY KEY,
  descricao TEXT,
  valor NUMERIC,
  tipo TEXT,
  categoria TEXT,
  status TEXT DEFAULT 'pendente',
  data_vencimento DATE,
  data_pagamento DATE,
  obs TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS admin_ausencias (
  id TEXT PRIMARY KEY,
  funcionario_id TEXT,
  tipo TEXT,
  data_inicio DATE,
  data_fim DATE,
  dias INTEGER,
  obs TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS admin_avaliacoes (
  id TEXT PRIMARY KEY,
  funcionario_id TEXT,
  periodo TEXT,
  nota INTEGER,
  pontos_fortes TEXT,
  pontos_melhoria TEXT,
  obs TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS: liberar acesso anônimo (mesmo padrão das outras tabelas)
ALTER TABLE admin_lancamentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_ausencias ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_avaliacoes ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "anon_all_lancamentos" ON admin_lancamentos FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "anon_all_ausencias"   ON admin_ausencias   FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "anon_all_avaliacoes"  ON admin_avaliacoes  FOR ALL TO anon USING (true) WITH CHECK (true);

-- Indexes para performance
CREATE INDEX IF NOT EXISTS idx_eventos_convidados_evento_id ON eventos_convidados(evento_id);
CREATE INDEX IF NOT EXISTS idx_wealth_followups_lead_id ON wealth_followups(lead_id);
CREATE INDEX IF NOT EXISTS idx_admin_ausencias_func ON admin_ausencias(funcionario_id);
CREATE INDEX IF NOT EXISTS idx_admin_avaliacoes_func ON admin_avaliacoes(funcionario_id);

-- AVALIAÇÃO 360°
CREATE TABLE IF NOT EXISTS admin_aval360_rodadas (
  id TEXT PRIMARY KEY,
  data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS admin_aval360_respostas (
  id TEXT PRIMARY KEY,
  rodada_id TEXT NOT NULL,
  data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE admin_aval360_rodadas ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_aval360_respostas ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "anon_all_aval360_rodadas"   ON admin_aval360_rodadas   FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "anon_all_aval360_respostas" ON admin_aval360_respostas FOR ALL TO anon USING (true) WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_aval360_respostas_rodada ON admin_aval360_respostas(rodada_id);
