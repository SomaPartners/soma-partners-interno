-- ============================================================
-- SOMA PARTNERS — SCHEMA COMPLETO
-- Execute no Supabase Dashboard > SQL Editor
-- ============================================================

-- 1. USUÁRIOS DO SISTEMA (login)
CREATE TABLE IF NOT EXISTS soma_usuarios (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  nome TEXT,
  senha_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CONCIERGE — Clientes
CREATE TABLE IF NOT EXISTS concierge_clientes (
  id TEXT PRIMARY KEY,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. CONCIERGE — Pagamentos
CREATE TABLE IF NOT EXISTS concierge_pagamentos (
  id TEXT PRIMARY KEY,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. CONCIERGE — Tarefas
CREATE TABLE IF NOT EXISTS concierge_tarefas (
  id TEXT PRIMARY KEY,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. CONCIERGE — Lembretes
CREATE TABLE IF NOT EXISTS concierge_lembretes (
  id TEXT PRIMARY KEY,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. CONCIERGE — Interações
CREATE TABLE IF NOT EXISTS concierge_interacoes (
  id TEXT PRIMARY KEY,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. WEALTH — Leads
CREATE TABLE IF NOT EXISTS wealth_leads (
  id TEXT PRIMARY KEY,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. WEALTH — Follow-ups
CREATE TABLE IF NOT EXISTS wealth_followups (
  id TEXT PRIMARY KEY,
  lead_id TEXT,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. EVENTOS
CREATE TABLE IF NOT EXISTS eventos (
  id TEXT PRIMARY KEY,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. EVENTOS — Convidados
CREATE TABLE IF NOT EXISTS eventos_convidados (
  id TEXT PRIMARY KEY,
  evento_id TEXT,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY — libera acesso via anon key
-- ============================================================

ALTER TABLE soma_usuarios        ENABLE ROW LEVEL SECURITY;
ALTER TABLE concierge_clientes   ENABLE ROW LEVEL SECURITY;
ALTER TABLE concierge_pagamentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE concierge_tarefas    ENABLE ROW LEVEL SECURITY;
ALTER TABLE concierge_lembretes  ENABLE ROW LEVEL SECURITY;
ALTER TABLE concierge_interacoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE wealth_leads         ENABLE ROW LEVEL SECURITY;
ALTER TABLE wealth_followups     ENABLE ROW LEVEL SECURITY;
ALTER TABLE eventos              ENABLE ROW LEVEL SECURITY;
ALTER TABLE eventos_convidados   ENABLE ROW LEVEL SECURITY;

CREATE POLICY "allow_all" ON soma_usuarios        FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON concierge_clientes   FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON concierge_pagamentos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON concierge_tarefas    FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON concierge_lembretes  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON concierge_interacoes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON wealth_leads         FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON wealth_followups     FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON eventos              FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON eventos_convidados   FOR ALL USING (true) WITH CHECK (true);

-- ============================================================
-- ÍNDICES para performance
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_wealth_followups_lead ON wealth_followups(lead_id);
CREATE INDEX IF NOT EXISTS idx_eventos_convidados_evento ON eventos_convidados(evento_id);
CREATE INDEX IF NOT EXISTS idx_concierge_pagamentos_data ON concierge_pagamentos USING GIN(data);
CREATE INDEX IF NOT EXISTS idx_concierge_tarefas_data ON concierge_tarefas USING GIN(data);
CREATE INDEX IF NOT EXISTS idx_concierge_lembretes_data ON concierge_lembretes USING GIN(data);
CREATE INDEX IF NOT EXISTS idx_concierge_interacoes_data ON concierge_interacoes USING GIN(data);
