# Soma Partners — Supabase + Wealth Module Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate Concierge and Eventos from localStorage to Supabase, build the Wealth CRM module, push everything to GitHub Pages.

**Architecture:** JSONB `data` column pattern — every table has `id TEXT PRIMARY KEY, data JSONB NOT NULL`. JS loads rows and extracts `.data`; saves by upserting `{id, data: obj}`. Minimal code changes to existing files. Convidados live in a separate `eventos_convidados` table (cross-page writes from inscricao.html).

**Tech Stack:** Supabase JS CDN v2 (`@supabase/supabase-js`), vanilla JS, GitHub Pages static HTML.

---

## Prerequisites

Before Task 2, user must provide:
- Supabase project URL (e.g. `https://abcxyz.supabase.co`)
- Supabase anon public key

---

## File Map

| File | Action |
|------|--------|
| `eventos.html` | Already staged (URL fix) — push in Task 1 |
| `concierge.html` | Replace data layer (Tasks 3-4) |
| `eventos.html` | Replace data layer (Task 5) |
| `inscricao.html` | Replace localStorage write (Task 6) |
| `wealth.html` | Create new file (Task 7) |
| `soma-partners.html` | Update Wealth card link (Task 8) |

---

## Task 1: Push eventos.html URL fix

**Files:** `eventos.html` (already staged)

- [ ] **Step 1: Verify staged content**

```bash
git diff --cached eventos.html
```
Expected: shows `inscricao.html` URL changed to `https://somapartners.github.io/Soma-Partners-Site-Interno/inscricao.html`

- [ ] **Step 2: Push to GitHub**

```bash
cd "/Users/guilherme/Library/Mobile Documents/com~apple~CloudDocs/Soma Partners/SITE INTERNO SOMA"
git remote set-url origin https://GITHUB_PAT@github.com/SomaPartners/Soma-Partners-Site-Interno.git
git push origin main
```
Expected: `Branch 'main' set up to track remote branch 'main' from 'origin'.`

---

## Task 2: Apply SQL schema in Supabase

**Action:** User runs this SQL in Supabase Dashboard → SQL Editor.

- [ ] **Step 1: Run the following SQL**

```sql
-- Concierge
CREATE TABLE IF NOT EXISTS concierge_clientes    (id TEXT PRIMARY KEY, data JSONB NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS concierge_pagamentos  (id TEXT PRIMARY KEY, data JSONB NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS concierge_tarefas     (id TEXT PRIMARY KEY, data JSONB NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS concierge_documentos  (id TEXT PRIMARY KEY, data JSONB NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS concierge_interacoes  (id TEXT PRIMARY KEY, data JSONB NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS concierge_lembretes   (id TEXT PRIMARY KEY, data JSONB NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW());

-- Eventos
CREATE TABLE IF NOT EXISTS eventos               (id TEXT PRIMARY KEY, data JSONB NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS eventos_convidados    (id TEXT PRIMARY KEY, evento_id TEXT NOT NULL, data JSONB NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW());

-- Wealth
CREATE TABLE IF NOT EXISTS wealth_leads          (id TEXT PRIMARY KEY, data JSONB NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS wealth_followups      (id TEXT PRIMARY KEY, lead_id TEXT NOT NULL, data JSONB NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW());

-- Disable RLS (internal tool, no auth)
ALTER TABLE concierge_clientes   ENABLE ROW LEVEL SECURITY;
ALTER TABLE concierge_pagamentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE concierge_tarefas    ENABLE ROW LEVEL SECURITY;
ALTER TABLE concierge_documentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE concierge_interacoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE concierge_lembretes  ENABLE ROW LEVEL SECURITY;
ALTER TABLE eventos              ENABLE ROW LEVEL SECURITY;
ALTER TABLE eventos_convidados   ENABLE ROW LEVEL SECURITY;
ALTER TABLE wealth_leads         ENABLE ROW LEVEL SECURITY;
ALTER TABLE wealth_followups     ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_all" ON concierge_clientes   FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON concierge_pagamentos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON concierge_tarefas    FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON concierge_documentos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON concierge_interacoes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON concierge_lembretes  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON eventos              FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON eventos_convidados   FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON wealth_leads         FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON wealth_followups     FOR ALL USING (true) WITH CHECK (true);
```

Expected: All tables created with green checkmarks.

---

## Task 3: Add shared Supabase helpers to concierge.html

**Files:** Modify `concierge.html`

The helper block replaces the old `loadData`/`saveData` functions and adds a loading overlay + toast. The SUPA_URL and SUPA_KEY values are filled in from the credentials the user provides.

- [ ] **Step 1: Add CDN script tag**

In `concierge.html`, add after the feather-icons script tag (line 8):
```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
```

- [ ] **Step 2: Add loading overlay HTML**

Add immediately after `<body>` (before `<!-- SIDEBAR -->`):
```html
<!-- LOADING OVERLAY -->
<div id="loading-overlay" style="position:fixed;inset:0;background:rgba(15,23,42,0.7);z-index:9999;display:flex;align-items:center;justify-content:center;display:none">
  <div style="display:flex;flex-direction:column;align-items:center;gap:12px">
    <div style="width:36px;height:36px;border:3px solid rgba(255,255,255,0.15);border-top-color:#818cf8;border-radius:50%;animation:spin 0.7s linear infinite"></div>
    <span style="color:rgba(255,255,255,0.7);font-size:13px;font-family:'Montserrat',sans-serif">Carregando...</span>
  </div>
</div>
<style>@keyframes spin{to{transform:rotate(360deg)}}</style>

<!-- TOAST -->
<div id="toast" style="position:fixed;bottom:24px;right:24px;z-index:9999;display:none;background:#1e293b;color:#fff;padding:12px 20px;border-radius:10px;font-size:13px;font-family:'Montserrat',sans-serif;box-shadow:0 8px 24px rgba(0,0,0,0.4);border-left:3px solid #10b981" id="toast"></div>
```

- [ ] **Step 3: Replace data layer in script block**

Find and replace the data layer section (lines 676-680):
```javascript
// OLD — remove these 5 lines:
const STORAGE_KEY = 'soma_concierge_v1';
function loadData(){try{const r=localStorage.getItem(STORAGE_KEY);if(r)return JSON.parse(r)}catch(e){}return{clientes:[],pagamentos:[],tarefas:[],documentos:[],interacoes:[],lembretes:[]}}
function saveData(d){localStorage.setItem(STORAGE_KEY,JSON.stringify(d))}
function uid(){return Date.now().toString(36)+Math.random().toString(36).substr(2,5)}
let DB=loadData();
```

Replace with:
```javascript
// ════ SUPABASE ════
const SUPA_URL = 'PLACEHOLDER_URL';
const SUPA_KEY = 'PLACEHOLDER_KEY';
const sb = supabase.createClient(SUPA_URL, SUPA_KEY);

function uid(){return Date.now().toString(36)+Math.random().toString(36).substr(2,5)}
let DB={clientes:[],pagamentos:[],tarefas:[],documentos:[],interacoes:[],lembretes:[]};

function showLoading(v){const el=document.getElementById('loading-overlay');if(el)el.style.display=v?'flex':'none'}
let _toastTimer;
function showToast(msg,type='success'){
  const el=document.getElementById('toast');if(!el)return;
  el.textContent=msg;
  el.style.borderLeftColor=type==='error'?'#ef4444':'#10b981';
  el.style.display='block';
  clearTimeout(_toastTimer);
  _toastTimer=setTimeout(()=>{el.style.display='none'},3000);
}
async function dbGet(table){
  const {data,error}=await sb.from(table).select('id,data').order('created_at');
  if(error){showToast('Erro ao carregar dados','error');return[]}
  return(data||[]).map(r=>r.data);
}
async function dbUpsert(table,obj){
  const {error}=await sb.from(table).upsert({id:obj.id,data:obj});
  if(error){showToast('Erro ao salvar','error');return false}
  return true;
}
async function dbDelete(table,id){
  const {error}=await sb.from(table).delete().eq('id',id);
  if(error){showToast('Erro ao excluir','error');return false}
  return true;
}

async function initDB(){
  showLoading(true);
  const [c,p,t,d,i,l]=await Promise.all([
    dbGet('concierge_clientes'),dbGet('concierge_pagamentos'),dbGet('concierge_tarefas'),
    dbGet('concierge_documentos'),dbGet('concierge_interacoes'),dbGet('concierge_lembretes')
  ]);
  DB={clientes:c,pagamentos:p,tarefas:t,documentos:d,interacoes:i,lembretes:l};
  showLoading(false);
  populateClienteSelects();
  navigate('dashboard');
}
```

---

## Task 4: Make concierge.html CRUD functions async

**Files:** Modify `concierge.html`

Replace each save/delete/update function. Find the exact line and replace.

- [ ] **Step 1: Replace saveCliente**

Find:
```javascript
function saveCliente(){
  const nome=document.getElementById('c-nome').value.trim();
  if(!nome){alert('Informe o nome do cliente');return}
  const id=document.getElementById('cliente-edit-id').value||uid();
  const data={id,nome,email:document.getElementById('c-email').value.trim(),telefone:document.getElementById('c-telefone').value.trim(),cpf:document.getElementById('c-cpf').value.trim(),nascimento:document.getElementById('c-nascimento').value,endereco:document.getElementById('c-endereco').value.trim(),obs:document.getElementById('c-obs').value.trim(),status:document.getElementById('c-status').value};
  const idx=DB.clientes.findIndex(c=>c.id===id);
  if(idx>=0)Object.assign(DB.clientes[idx],data);else{data.dataCadastro=today();DB.clientes.push(data)}
  saveData(DB);closeModal('modal-cliente');populateClienteSelects();renderSection(currentSection());
}
```

Replace with:
```javascript
async function saveCliente(){
  const nome=document.getElementById('c-nome').value.trim();
  if(!nome){alert('Informe o nome do cliente');return}
  const id=document.getElementById('cliente-edit-id').value||uid();
  const data={id,nome,email:document.getElementById('c-email').value.trim(),telefone:document.getElementById('c-telefone').value.trim(),cpf:document.getElementById('c-cpf').value.trim(),nascimento:document.getElementById('c-nascimento').value,endereco:document.getElementById('c-endereco').value.trim(),obs:document.getElementById('c-obs').value.trim(),status:document.getElementById('c-status').value};
  const idx=DB.clientes.findIndex(c=>c.id===id);
  if(idx<0)data.dataCadastro=today();
  if(!await dbUpsert('concierge_clientes',data))return;
  if(idx>=0)Object.assign(DB.clientes[idx],data);else DB.clientes.push(data);
  closeModal('modal-cliente');populateClienteSelects();renderSection(currentSection());
}
```

- [ ] **Step 2: Replace savePagamento**

Find:
```javascript
function savePagamento(){
  const clienteId=document.getElementById('pgt-cliente').value;
  const desc=document.getElementById('pgt-desc').value.trim();
  const valor=document.getElementById('pgt-valor').value;
  const venc=document.getElementById('pgt-vencimento').value;
  if(!clienteId||!desc||!valor||!venc){alert('Preencha os campos obrigatórios');return}
  const id=document.getElementById('pgt-edit-id').value||uid();
  const data={id,clienteId,descricao:desc,valor:parseFloat(valor),dataVencimento:venc,status:document.getElementById('pgt-status').value,obs:document.getElementById('pgt-obs').value.trim()};
  const idx=DB.pagamentos.findIndex(p=>p.id===id);
  if(idx>=0)Object.assign(DB.pagamentos[idx],data);else DB.pagamentos.push(data);
  saveData(DB);closeModal('modal-pagamento');renderSection(currentSection());
}
```

Replace with:
```javascript
async function savePagamento(){
  const clienteId=document.getElementById('pgt-cliente').value;
  const desc=document.getElementById('pgt-desc').value.trim();
  const valor=document.getElementById('pgt-valor').value;
  const venc=document.getElementById('pgt-vencimento').value;
  if(!clienteId||!desc||!valor||!venc){alert('Preencha os campos obrigatórios');return}
  const id=document.getElementById('pgt-edit-id').value||uid();
  const data={id,clienteId,descricao:desc,valor:parseFloat(valor),dataVencimento:venc,status:document.getElementById('pgt-status').value,obs:document.getElementById('pgt-obs').value.trim()};
  if(!await dbUpsert('concierge_pagamentos',data))return;
  const idx=DB.pagamentos.findIndex(p=>p.id===id);
  if(idx>=0)Object.assign(DB.pagamentos[idx],data);else DB.pagamentos.push(data);
  closeModal('modal-pagamento');renderSection(currentSection());
}
```

- [ ] **Step 3: Replace marcarPago**

Find:
```javascript
function marcarPago(id){const p=DB.pagamentos.find(x=>x.id===id);if(p){p.status='pago';saveData(DB);renderSection(currentSection())}}
```

Replace with:
```javascript
async function marcarPago(id){const p=DB.pagamentos.find(x=>x.id===id);if(!p)return;p.status='pago';await dbUpsert('concierge_pagamentos',p);renderSection(currentSection())}
```

- [ ] **Step 4: Replace saveTarefa**

Find:
```javascript
function saveTarefa(){
  const titulo=document.getElementById('tar-titulo').value.trim();
  if(!titulo){alert('Informe o título da tarefa');return}
  const id=document.getElementById('tar-edit-id').value||uid();
  const data={id,clienteId:document.getElementById('tar-cliente').value,titulo,desc:document.getElementById('tar-desc').value.trim(),prioridade:document.getElementById('tar-prioridade').value,status:document.getElementById('tar-status').value,prazo:document.getElementById('tar-prazo').value,responsavel:document.getElementById('tar-responsavel').value.trim()};
  const idx=DB.tarefas.findIndex(t=>t.id===id);
  if(idx>=0)Object.assign(DB.tarefas[idx],data);else DB.tarefas.push(data);
  saveData(DB);closeModal('modal-tarefa');renderSection(currentSection());
}
```

Replace with:
```javascript
async function saveTarefa(){
  const titulo=document.getElementById('tar-titulo').value.trim();
  if(!titulo){alert('Informe o título da tarefa');return}
  const id=document.getElementById('tar-edit-id').value||uid();
  const data={id,clienteId:document.getElementById('tar-cliente').value,titulo,desc:document.getElementById('tar-desc').value.trim(),prioridade:document.getElementById('tar-prioridade').value,status:document.getElementById('tar-status').value,prazo:document.getElementById('tar-prazo').value,responsavel:document.getElementById('tar-responsavel').value.trim()};
  if(!await dbUpsert('concierge_tarefas',data))return;
  const idx=DB.tarefas.findIndex(t=>t.id===id);
  if(idx>=0)Object.assign(DB.tarefas[idx],data);else DB.tarefas.push(data);
  closeModal('modal-tarefa');renderSection(currentSection());
}
```

- [ ] **Step 5: Replace concluirTarefa**

Find:
```javascript
function concluirTarefa(id){const t=DB.tarefas.find(x=>x.id===id);if(t){t.status='concluida';saveData(DB);renderSection(currentSection())}}
```

Replace with:
```javascript
async function concluirTarefa(id){const t=DB.tarefas.find(x=>x.id===id);if(!t)return;t.status='concluida';await dbUpsert('concierge_tarefas',t);renderSection(currentSection())}
```

- [ ] **Step 6: Replace saveDocumento**

Find:
```javascript
function saveDocumento(){
  const clienteId=document.getElementById('doc-cliente').value;
  const nome=document.getElementById('doc-nome').value.trim();
  if(!nome){alert('Informe o nome do documento');return}
  DB.documentos.push({id:uid(),clienteId,nome,tipo:document.getElementById('doc-tipo').value,arquivo:document.getElementById('doc-arquivo').value.trim(),obs:document.getElementById('doc-obs').value.trim(),dataUpload:today()});
  saveData(DB);closeModal('modal-documento');renderSection(currentSection());
}
```

Replace with:
```javascript
async function saveDocumento(){
  const clienteId=document.getElementById('doc-cliente').value;
  const nome=document.getElementById('doc-nome').value.trim();
  if(!nome){alert('Informe o nome do documento');return}
  const obj={id:uid(),clienteId,nome,tipo:document.getElementById('doc-tipo').value,arquivo:document.getElementById('doc-arquivo').value.trim(),obs:document.getElementById('doc-obs').value.trim(),dataUpload:today()};
  if(!await dbUpsert('concierge_documentos',obj))return;
  DB.documentos.push(obj);
  closeModal('modal-documento');renderSection(currentSection());
}
```

- [ ] **Step 7: Replace saveInteracao**

Find:
```javascript
function saveInteracao(){
  const clienteId=document.getElementById('int-cliente').value;
  const desc=document.getElementById('int-desc').value.trim();
  const data=document.getElementById('int-data').value;
  if(!clienteId||!desc||!data){alert('Preencha os campos obrigatórios');return}
  DB.interacoes.push({id:uid(),clienteId,tipo:document.getElementById('int-tipo').value,data,desc,resolucao:document.getElementById('int-resolucao').value.trim()});
  saveData(DB);closeModal('modal-interacao');renderSection(currentSection());
}
```

Replace with:
```javascript
async function saveInteracao(){
  const clienteId=document.getElementById('int-cliente').value;
  const desc=document.getElementById('int-desc').value.trim();
  const data=document.getElementById('int-data').value;
  if(!clienteId||!desc||!data){alert('Preencha os campos obrigatórios');return}
  const obj={id:uid(),clienteId,tipo:document.getElementById('int-tipo').value,data,desc,resolucao:document.getElementById('int-resolucao').value.trim()};
  if(!await dbUpsert('concierge_interacoes',obj))return;
  DB.interacoes.push(obj);
  closeModal('modal-interacao');renderSection(currentSection());
}
```

- [ ] **Step 8: Replace saveLembrete**

Find:
```javascript
function saveLembrete(){
  const titulo=document.getElementById('lem-titulo').value.trim();
  const data=document.getElementById('lem-data').value;
  if(!titulo||!data){alert('Preencha título e data');return}
  DB.lembretes.push({id:uid(),clienteId:document.getElementById('lem-cliente').value,titulo,data,prioridade:document.getElementById('lem-prioridade').value,obs:document.getElementById('lem-obs').value.trim(),feito:false});
  saveData(DB);closeModal('modal-lembrete');renderSection(currentSection());
}
```

Replace with:
```javascript
async function saveLembrete(){
  const titulo=document.getElementById('lem-titulo').value.trim();
  const data=document.getElementById('lem-data').value;
  if(!titulo||!data){alert('Preencha título e data');return}
  const obj={id:uid(),clienteId:document.getElementById('lem-cliente').value,titulo,data,prioridade:document.getElementById('lem-prioridade').value,obs:document.getElementById('lem-obs').value.trim(),feito:false};
  if(!await dbUpsert('concierge_lembretes',obj))return;
  DB.lembretes.push(obj);
  closeModal('modal-lembrete');renderSection(currentSection());
}
```

- [ ] **Step 9: Replace marcarLembreteFeito**

Find:
```javascript
function marcarLembreteFeito(id){const l=DB.lembretes.find(x=>x.id===id);if(l){l.feito=true;saveData(DB);renderSection(currentSection())}}
```

Replace with:
```javascript
async function marcarLembreteFeito(id){const l=DB.lembretes.find(x=>x.id===id);if(!l)return;l.feito=true;await dbUpsert('concierge_lembretes',l);renderSection(currentSection())}
```

- [ ] **Step 10: Replace confirmDelete**

Find:
```javascript
function confirmDelete(type,id){
  document.getElementById('confirm-delete-btn').onclick=()=>{
    const map={cliente:'clientes',pagamento:'pagamentos',tarefa:'tarefas',documento:'documentos',interacao:'interacoes',lembrete:'lembretes'};
    DB[map[type]]=DB[map[type]].filter(x=>x.id!==id);
    saveData(DB);closeModal('modal-confirm');populateClienteSelects();renderSection(currentSection());
  };
  openModal('modal-confirm');
}
```

Replace with:
```javascript
function confirmDelete(type,id){
  const tableMap={cliente:'concierge_clientes',pagamento:'concierge_pagamentos',tarefa:'concierge_tarefas',documento:'concierge_documentos',interacao:'concierge_interacoes',lembrete:'concierge_lembretes'};
  const keyMap={cliente:'clientes',pagamento:'pagamentos',tarefa:'tarefas',documento:'documentos',interacao:'interacoes',lembrete:'lembretes'};
  document.getElementById('confirm-delete-btn').onclick=async()=>{
    if(!await dbDelete(tableMap[type],id))return;
    DB[keyMap[type]]=DB[keyMap[type]].filter(x=>x.id!==id);
    closeModal('modal-confirm');populateClienteSelects();renderSection(currentSection());
  };
  openModal('modal-confirm');
}
```

- [ ] **Step 11: Replace init call at bottom of script**

Find:
```javascript
// INIT
populateClienteSelects();
renderDashboard();
```

Replace with:
```javascript
// INIT
initDB();
```

- [ ] **Step 12: Commit**

```bash
cd "/Users/guilherme/Library/Mobile Documents/com~apple~CloudDocs/Soma Partners/SITE INTERNO SOMA"
git add concierge.html
git commit -m "feat: migrate concierge to Supabase"
```

---

## Task 5: Supabase integration — eventos.html + inscricao.html

**Files:** Modify `eventos.html`, modify `inscricao.html`

### eventos.html

- [ ] **Step 1: Add CDN script tag**

Add after `<title>` or existing scripts in `<head>`:
```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
```

- [ ] **Step 2: Add loading overlay + toast HTML**

Add immediately after `<body>`:
```html
<div id="loading-overlay" style="position:fixed;inset:0;background:rgba(11,30,48,0.8);z-index:9999;display:none;align-items:center;justify-content:center">
  <div style="display:flex;flex-direction:column;align-items:center;gap:12px">
    <div style="width:36px;height:36px;border:3px solid rgba(255,255,255,0.15);border-top-color:#818cf8;border-radius:50%;animation:spin 0.7s linear infinite"></div>
    <span style="color:rgba(255,255,255,0.7);font-size:13px;font-family:'Montserrat',sans-serif">Carregando...</span>
  </div>
</div>
<div id="toast" style="position:fixed;bottom:24px;right:24px;z-index:9999;display:none;background:#1e293b;color:#fff;padding:12px 20px;border-radius:10px;font-size:13px;font-family:'Montserrat',sans-serif;box-shadow:0 8px 24px rgba(0,0,0,0.4);border-left:3px solid #10b981"></div>
<style>@keyframes spin{to{transform:rotate(360deg)}}</style>
```

- [ ] **Step 3: Replace data layer**

Find:
```javascript
// ════ DATA ════
const KEY = 'soma_eventos_v1';
function load(){try{const r=localStorage.getItem(KEY);if(r)return JSON.parse(r)}catch(e){}return{eventos:[]}}
function save(d){localStorage.setItem(KEY,JSON.stringify(d))}
function uid(){return Date.now().toString(36)+Math.random().toString(36).substr(2,5)}
let DB = load();
```

Replace with:
```javascript
// ════ SUPABASE ════
const SUPA_URL = 'PLACEHOLDER_URL';
const SUPA_KEY = 'PLACEHOLDER_KEY';
const sb = supabase.createClient(SUPA_URL, SUPA_KEY);

function uid(){return Date.now().toString(36)+Math.random().toString(36).substr(2,5)}
let DB = {eventos:[]};

function showLoading(v){const el=document.getElementById('loading-overlay');if(el)el.style.display=v?'flex':'none'}
let _toastTimer;
function showToast(msg,type='success'){
  const el=document.getElementById('toast');if(!el)return;
  el.textContent=msg;el.style.borderLeftColor=type==='error'?'#ef4444':'#10b981';
  el.style.display='block';clearTimeout(_toastTimer);
  _toastTimer=setTimeout(()=>{el.style.display='none'},3000);
}

// Generic helpers
async function dbGet(table){
  const {data,error}=await sb.from(table).select('id,data').order('created_at');
  if(error){showToast('Erro ao carregar dados','error');return[]}
  return(data||[]).map(r=>r.data);
}
async function dbUpsert(table,obj,extra){
  const row={id:obj.id,data:obj,...(extra||{})};
  const {error}=await sb.from(table).upsert(row);
  if(error){showToast('Erro ao salvar','error');return false}
  return true;
}
async function dbDelete(table,id){
  const {error}=await sb.from(table).delete().eq('id',id);
  if(error){showToast('Erro ao excluir','error');return false}
  return true;
}

async function initDB(){
  showLoading(true);
  const eventos=await dbGet('eventos');
  const {data:convRows}=await sb.from('eventos_convidados').select('id,evento_id,data').order('created_at');
  const convMap={};
  (convRows||[]).forEach(r=>{if(!convMap[r.evento_id])convMap[r.evento_id]=[];convMap[r.evento_id].push({...r.data,_rowId:r.id})});
  DB.eventos=eventos.map(e=>({...e,convidados:convMap[e.id]||[]}));
  showLoading(false);
  renderGrid();
}
```

- [ ] **Step 4: Replace saveEvento**

Find:
```javascript
function saveEvento(){
  const nome = document.getElementById('ev-nome').value.trim();
  if(!nome){alert('Informe o nome do evento');return}
  const id = document.getElementById('ev-edit-id').value || uid();
  const existing = DB.eventos.find(e=>e.id===id);
  const data = {
    id, nome,
    data: document.getElementById('ev-data').value,
    horario: document.getElementById('ev-horario').value,
    local: document.getElementById('ev-local').value.trim(),
    objetivo: document.getElementById('ev-objetivo').value,
    publico: document.getElementById('ev-publico').value.trim(),
    status: document.getElementById('ev-status').value,
    desc: document.getElementById('ev-desc').value.trim(),
    inscricao: document.getElementById('ev-inscricao').value.trim(),
    credenciamento: document.getElementById('ev-credenciamento').value.trim(),
    cronograma: existing?.cronograma||[],
    patrocinios: existing?.patrocinios||[],
    checklist: existing?.checklist||[],
    compras: existing?.compras||[],
    convidados: existing?.convidados||[],
    equipe: existing?.equipe||[],
    createdAt: existing?.createdAt||today(),
  };
  const idx = DB.eventos.findIndex(e=>e.id===id);
  if(idx>=0) Object.assign(DB.eventos[idx],data); else DB.eventos.push(data);
  save(DB);
  closeModal('modal-evento');
  renderGrid();
  if(currentEventId===id) openDetail(id);
}
```

Replace with:
```javascript
async function saveEvento(){
  const nome = document.getElementById('ev-nome').value.trim();
  if(!nome){alert('Informe o nome do evento');return}
  const id = document.getElementById('ev-edit-id').value || uid();
  const existing = DB.eventos.find(e=>e.id===id);
  const data = {
    id, nome,
    data: document.getElementById('ev-data').value,
    horario: document.getElementById('ev-horario').value,
    local: document.getElementById('ev-local').value.trim(),
    objetivo: document.getElementById('ev-objetivo').value,
    publico: document.getElementById('ev-publico').value.trim(),
    status: document.getElementById('ev-status').value,
    desc: document.getElementById('ev-desc').value.trim(),
    inscricao: document.getElementById('ev-inscricao').value.trim(),
    credenciamento: document.getElementById('ev-credenciamento').value.trim(),
    cronograma: existing?.cronograma||[],
    patrocinios: existing?.patrocinios||[],
    checklist: existing?.checklist||[],
    compras: existing?.compras||[],
    equipe: existing?.equipe||[],
    createdAt: existing?.createdAt||today(),
  };
  if(!await dbUpsert('eventos',data))return;
  const idx = DB.eventos.findIndex(e=>e.id===id);
  const full = {...data, convidados: existing?.convidados||[]};
  if(idx>=0) Object.assign(DB.eventos[idx],full); else DB.eventos.push(full);
  closeModal('modal-evento');
  renderGrid();
  if(currentEventId===id) openDetail(id);
}
```

- [ ] **Step 5: Replace delete evento logic**

Find `id="confirm-delete-btn"` handler. In eventos.html the delete button calls:
```javascript
document.getElementById('confirm-delete-btn').onclick=async()=>{
```

Find the full confirmDelete function in eventos.html and replace it with:
```javascript
function confirmDeleteEvento(id){
  document.getElementById('confirm-delete-btn').onclick=async()=>{
    // Delete convidados first (no cascade in schema)
    const e=DB.eventos.find(x=>x.id===id);
    const guests=e?.convidados||[];
    await Promise.all(guests.map(g=>dbDelete('eventos_convidados',g._rowId||g.id)));
    if(!await dbDelete('eventos',id))return;
    DB.eventos=DB.eventos.filter(x=>x.id!==id);
    closeModal('modal-confirm');
    if(currentEventId===id){currentEventId=null;document.getElementById('detail-panel').classList.remove('open')}
    renderGrid();
  };
  openModal('modal-confirm');
}
```

Then update every call to `confirmDeleteEvento` (search for the old delete trigger in the HTML and update the `onclick` to call `confirmDeleteEvento(id)` instead).

- [ ] **Step 6: Replace addGuest / updateGuestRSVP / removeGuest**

Find:
```javascript
function addGuest(){
  const name=document.getElementById('new-guest-name').value.trim();if(!name)return;
  const e=DB.eventos.find(x=>x.id===currentEventId);if(!e.convidados)e.convidados=[];
  e.convidados.push({id:uid(),name,info:document.getElementById('new-guest-info').value.trim(),rsvp:document.getElementById('new-guest-rsvp').value});
  save(DB);['new-guest-name','new-guest-info'].forEach(f=>document.getElementById(f).value='');
  renderGuests(e);refreshStats();
}
function updateGuestRSVP(i,val){const e=DB.eventos.find(x=>x.id===currentEventId);e.convidados[i].rsvp=val;save(DB);renderGuests(e);refreshStats()}
function removeGuest(i){const e=DB.eventos.find(x=>x.id===currentEventId);e.convidados.splice(i,1);save(DB);renderGuests(e);refreshStats()}
```

Replace with:
```javascript
async function addGuest(){
  const name=document.getElementById('new-guest-name').value.trim();if(!name)return;
  const e=DB.eventos.find(x=>x.id===currentEventId);if(!e)return;
  if(!e.convidados)e.convidados=[];
  const gId=uid();
  const guest={id:gId,name,info:document.getElementById('new-guest-info').value.trim(),rsvp:document.getElementById('new-guest-rsvp').value,_rowId:gId};
  const {error}=await sb.from('eventos_convidados').upsert({id:gId,evento_id:e.id,data:guest});
  if(error){showToast('Erro ao adicionar convidado','error');return}
  e.convidados.push(guest);
  ['new-guest-name','new-guest-info'].forEach(f=>document.getElementById(f).value='');
  renderGuests(e);refreshStats();
}
async function updateGuestRSVP(i,val){
  const e=DB.eventos.find(x=>x.id===currentEventId);if(!e)return;
  e.convidados[i].rsvp=val;
  const g=e.convidados[i];
  await sb.from('eventos_convidados').update({data:g}).eq('id',g._rowId||g.id);
  renderGuests(e);refreshStats();
}
async function removeGuest(i){
  const e=DB.eventos.find(x=>x.id===currentEventId);if(!e)return;
  const g=e.convidados[i];
  await dbDelete('eventos_convidados',g._rowId||g.id);
  e.convidados.splice(i,1);
  renderGuests(e);refreshStats();
}
```

- [ ] **Step 7: Replace all other `save(DB)` calls**

Each remaining `save(DB)` call occurs in functions that modify JSONB fields (checklist, compras, equipe, cronograma, patrocinios). Replace each with an upsert of the evento object (without convidados):

Pattern: find each function that calls `save(DB)` and update it:
```javascript
// Instead of: save(DB)
// Use: const e=DB.eventos.find(x=>x.id===currentEventId); const {convidados,...eData}=e; await dbUpsert('eventos',eData);
```

Affected functions: `toggleChecklist`, `addChecklistItem`, `removeChecklistItem`, `addCompra`, `updateCompraStatus`, `removeCompra`, `addTeamMember`, `removeTeam`, `addCronograma`, `removeCronograma`, `addPatrocinio`, `removePatrocinio`.

For each of these functions, replace `save(DB)` or `save(DB);` with:
```javascript
const ev=DB.eventos.find(x=>x.id===currentEventId);const {convidados,...evData}=ev;await dbUpsert('eventos',evData);
```

And add `async` to the function declaration.

- [ ] **Step 8: Replace init call at bottom**

Find the last line that calls `renderGrid()` or initializes the page. Replace with:
```javascript
initDB();
```

### inscricao.html

- [ ] **Step 9: Add CDN to inscricao.html**

Add in `<head>`:
```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
```

- [ ] **Step 10: Replace localStorage block in inscricao.html**

Find:
```javascript
  // Save to localStorage so it appears in eventos.html guest list
  try {
    const STORAGE_KEY = 'soma_eventos_v1';
    const db = JSON.parse(localStorage.getItem(STORAGE_KEY)||'{"eventos":[]}');
    const ev = db.eventos.find(x => x.id === evId);
    if(ev) {
      if(!ev.convidados) ev.convidados = [];
      // Avoid duplicate by email
      const already = ev.convidados.find(c => c.info === email);
      if(!already) {
        ev.convidados.push({
          id: Date.now().toString(36),
          name: nome,
          info: email,
          telefone, cpf, empresa, obs,
          rsvp: 'confirmado',
          origem: 'formulario'
        });
        localStorage.setItem(STORAGE_KEY, JSON.stringify(db));
      }
    }
  } catch(e) {}
```

Replace with:
```javascript
  // Save guest to Supabase
  try {
    const SUPA_URL = 'PLACEHOLDER_URL';
    const SUPA_KEY = 'PLACEHOLDER_KEY';
    const sbClient = supabase.createClient(SUPA_URL, SUPA_KEY);
    if(evId) {
      // Check for duplicate by email
      const {data:existing}=await sbClient.from('eventos_convidados').select('id').eq('evento_id',evId).eq('data->>info',email).maybeSingle();
      if(!existing){
        const gId=Date.now().toString(36)+Math.random().toString(36).substr(2,4);
        const guest={id:gId,name:nome,info:email,telefone,cpf,empresa,obs,rsvp:'confirmado',origem:'formulario',_rowId:gId};
        await sbClient.from('eventos_convidados').insert({id:gId,evento_id:evId,data:guest});
      }
    }
  } catch(e) {console.warn('Supabase write failed',e)}
```

Also change the function signature to `async function submitForm(e)`.

- [ ] **Step 11: Commit**

```bash
git add eventos.html inscricao.html
git commit -m "feat: migrate eventos and inscricao to Supabase"
```

---

## Task 6: Build wealth.html

**Files:** Create `wealth.html`

This is a new file. Full content below — write it exactly.

- [ ] **Step 1: Create wealth.html**

Create file at `/Users/guilherme/Library/Mobile Documents/com~apple~CloudDocs/Soma Partners/SITE INTERNO SOMA/wealth.html` with the complete implementation. The file follows the exact same structure as concierge.html: dark sidebar `#0f172a`, content area `#f1f5f9`, Montserrat, inline SVG icons.

Key sections:
- HTML structure: sidebar + main + modals
- CSS: copy base from concierge.html, add kanban-specific styles
- JS: Supabase data layer, 4 sections (dashboard/pipeline/followups/leads)

Kanban column structure:
```html
<div class="kanban-board">
  <div class="kanban-col" id="col-prospeccao">...</div>
  <div class="kanban-col" id="col-qualificacao">...</div>
  <div class="kanban-col" id="col-reuniao">...</div>
  <div class="kanban-col" id="col-proposta">...</div>
  <div class="kanban-col" id="col-fechado">...</div>
</div>
```

Card urgency logic:
```javascript
function cardUrgency(lead){
  if(!lead.data_proxima_acao)return'none';
  const diff=Math.ceil((new Date(lead.data_proxima_acao)-new Date(today()))/(1000*60*60*24));
  if(diff<0)return'overdue';   // red border
  if(diff<=2)return'soon';     // yellow tint
  return'ok';
}
```

- [ ] **Step 2: Commit**

```bash
git add wealth.html
git commit -m "feat: add Wealth CRM module"
```

---

## Task 7: Update soma-partners.html

**Files:** Modify `soma-partners.html`

- [ ] **Step 1: Change Wealth card onclick**

Find:
```javascript
onclick="alert('Módulo Wealth — em breve!')"
```

Replace with:
```javascript
onclick="window.location.href='wealth.html'"
```

- [ ] **Step 2: Commit**

```bash
git add soma-partners.html
git commit -m "feat: link Wealth module from landing page"
```

---

## Task 8: Final push

- [ ] **Step 1: Push all commits**

```bash
cd "/Users/guilherme/Library/Mobile Documents/com~apple~CloudDocs/Soma Partners/SITE INTERNO SOMA"
git push origin main
```

Expected: All commits pushed. GitHub Pages will deploy automatically within ~60 seconds.

- [ ] **Step 2: Verify live URLs**

Open in browser:
- `https://somapartners.github.io/Soma-Partners-Site-Interno/` — landing page
- `https://somapartners.github.io/Soma-Partners-Site-Interno/concierge.html` — Concierge (Supabase)
- `https://somapartners.github.io/Soma-Partners-Site-Interno/eventos.html` — Eventos (Supabase)
- `https://somapartners.github.io/Soma-Partners-Site-Interno/wealth.html` — Wealth module
