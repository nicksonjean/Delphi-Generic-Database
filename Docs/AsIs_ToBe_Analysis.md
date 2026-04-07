# Generic Database Demo — AsIs / ToBe Analysis

## 1. AsIs — Estado Atual

### 1.1 Visão Geral

O projeto `Delphi-Generic-Database` é uma biblioteca FMX que abstrai múltiplos engines de banco de dados (FireDAC, dbExpress, ZeOS, UniDAC) via Strategy Pattern. Atualmente, as demos estão fragmentadas em **4 projetos independentes**, cada um com seu próprio `.dpr`, `.dproj` e form principal.

```
Demo/
├── GenericConnector.dpr         → Testa binding de componentes FMX
├── GenericDataTypes.dpr         → Testa tipos de dados (Array, Float, DateTime)
├── GenericPagNav.dpr            → Testa navegação/paginação
└── GenericQueryBuilder.dpr      → Testa construção dinâmica de SQL
```

---

### 1.2 Projetos Existentes — Detalhe

#### 1.2.1 GenericConnector
**Arquivo:** `GenericConnectorForm.fmx` / `GenericConnectorForm.pas`

**Propósito:** Demonstra o binding de resultados de query em componentes FMX nativos para todos os bancos de dados suportados.

**Estrutura de UI:**
- `TTabControl` principal com aba "Database Connectors"
- Sub-`TTabControl` com 6 abas (SQLite, Firebird/Interbase, MySQL/MariaDB, PostgreSQL, SQL Server, Oracle)
- Cada aba contém, via `TGridPanelLayout` (3 colunas × 2 linhas):
  - **Coluna 1:** `TComboBox` + `TListBox` (com `TSearchBox`)
  - **Coluna 2:** `TEdit` + `TListView`
  - **Coluna 3:** `TComboEdit` + `TStringGrid` + `TGrid`
- 2 botões de teste: Button1 (FireDAC) e Button2 (dbExpress)

**Padrões demonstrados:**
- `SmartPointer<TConnection>` — lifecycle automático
- `TQueryBuilder.ForConnection()` — construção fluente de queries
- `TConnector.ToCombo()`, `ToListBox()`, `ToGrid()`, `ToListView()` — binding de componentes
- Filtros JSON: `'{"Index":1}'`, `'{"Field":{"Estado":"Bahia"}}'`

**Limitações:**
- Conexão hardcoded por tab (SQLite usa arquivo local, outros via localhost)
- Sem interface para editar parâmetros de conexão
- Código de conexão duplicado em cada `TabDBXxxClick`
- Sem persistência de configuração

---

#### 1.2.2 GenericDataTypes
**Arquivo:** `GenericDataTypesForm.fmx` / `GenericDataTypesForm.pas`

**Propósito:** Teste massivo dos tipos customizados do projeto.

**Estrutura de UI:**
- `TTabControl` → aba "Data Types"
- Sub-`TTabControl` com 4 abas:
  - **Strings** — (vazio, sem implementação)
  - **Floats** — Formatação e cálculo numérico
  - **DateTime** — (vazio, sem implementação)
  - **Arrays** — Testa `TArrayString`, `TArrayVariant`, `TArrayField`

**Tab Arrays:**
- 3 `TComboBox` (um por tipo de array)
- Métodos testados: Fetch, Copy, Clone, ToList, ToTags, ToXML, ToJSON
- `TMemo` para exibir resultados
- Conecta em MySQL (hardcoded) para popular dados

**Tab Floats:**
- `GroupBox` "Float Format": 7 linhas de testes com `EditLength`, `EditDecimal`, `ComboBoxResult`
- Botões `FormatExplicit` e `FormatImplicit`
- `GroupBox` "Float Calculate": 7 operações com `EditCalculate`, `EditAmount`, `EditOperation`
- Botão `Calculate`
- `TMemo` para resultados

**Limitações:**
- Abas Strings e DateTime sem implementação
- Conexão MySQL hardcoded
- Sem documentação inline dos métodos testados

---

#### 1.2.3 GenericPagNav
**Arquivo:** `GenericPagNavForm.fmx` / `GenericPagNavForm.pas`

**Propósito:** Demonstra padrões de paginação e navegação para datasets.

**Estrutura de UI:**
- Aba "Paginators && Navigators"
- `TGridPanelLayout` 2 colunas:
  - **Esquerda — Original:** `TBindNavigator` (data-binding nativo FMX)
  - **Direita — Minimal + Full:** 2 `TGroupBox` empilhados
    - Minimal: `TEdit` + `TGrid` + 4 `TCornerButton` (First, Prior, Next, Last)
    - Full: `TEdit` + `TGrid` + 10 `TCornerButton` (+ Insert, Delete, Edit, Post, Cancel, Refresh)
- Botão de teste para `TArrayString`/`TArrayVariant` com `SmartPointer`

**Limitações:**
- Navegadores sem dados conectados (grids vazios)
- Sem integração com `TConnector`
- Sem paginação server-side

---

#### 1.2.4 GenericQueryBuilder
**Arquivo:** `GenericQueryBuilderForm.fmx` / `GenericQueryBuilderForm.pas`

**Propósito:** Demonstra construção dinâmica de SQL via `TQueryBuilder`.

**Estrutura de UI:**
- Aba "Query Builder"
- `TGroupBox` "Query Arrays" com 3 `TComboBox`:
  - `TArrayString` → operações: Insert, Update, Delete, Replace, Upsert
  - `TArrayVariant` → mesmas operações
  - `TArrayField` → mesmas operações
- `TMemo` para exibir queries geradas

**Limitações:**
- **Nenhuma implementação** — handlers vazios
- Sem preview de SQL
- Sem execução real de queries
- Sem conexão ao banco

---

### 1.3 Arquitetura Source

```
Source/
├── Connection/          # TConnection, TQuery, TQueryBuilder + engines (FireDAC, dbExpress, ZeOS, UniDAC)
│   └── Config/          # Loaders: INI, JSON, XML, YAML, TOML
├── Connector/           # TConnector — binding para componentes FMX
├── Types/               # TArrayString, TArrayVariant, TArrayField, TArrayAssoc, TFloat, TDateTime
├── Helpers/             # Class helpers: TGrid, TListBox, TListView, TComboBox, TComboEdit, TEdit
├── Extensions/          # Extensions: TEdit, TListView (multi-versão Berlin..Sydney)
├── SmartPointer/        # RAII — TSmartPointer<T>, ISmartPointer<T>
├── EventDriven/         # MVE pattern
└── Reflection/          # RTTI, MimeType, Registry
```

**Engines suportados:** FireDAC, dbExpress, ZeOS, UniDAC  
**Bancos suportados:** SQLite, MySQL/MariaDB, Firebird, Interbase, PostgreSQL, SQL Server, Oracle  
**Formatos de config:** INI, JSON, XML, YAML, TOML  

---

## 2. ToBe — Estado Desejado

### 2.1 Objetivo

Criar **um único projeto demo** `GenericDemo.dpr` com **um form principal** (`GenericDemoForm`) que encapsula todas as funcionalidades via **menu sanduíche** (hamburger menu). Cada seção é implementada como um `TFrame` carregado dinamicamente na área de conteúdo.

---

### 2.2 Estrutura do Novo Projeto

```
Demo/
├── GenericDemo.dpr              → Projeto único consolidado
├── GenericDemoForm.fmx          → Form principal (hamburger menu shell)
├── GenericDemoForm.pas
└── Frames/
    ├── Frame.Connection.fmx     → Seção: Gerenciador de Conexão
    ├── Frame.Connection.pas
    ├── Frame.Connector.fmx      → Seção: Teste de Connector
    ├── Frame.Connector.pas
    ├── Frame.DataTypes.fmx      → Seção: Tipos de Dados
    ├── Frame.DataTypes.pas
    └── Frame.PagNav.fmx         → Seção: Paginação e Navegação
    └── Frame.PagNav.pas
```

---

### 2.3 Layout do Form Principal

```
╔══════════════════════════════════════════════════════════════╗
║  [☰]   Generic Database Demo Suite          [Section Name]  ║  ← Header (60px, azul escuro)
╠══╦═══════════════════════════════════════════════════════════╣
║  ║                                                           ║
║S ║                                                           ║
║i ║              Content Area                                 ║
║d ║          (Frame ativo carregado aqui)                     ║
║e ║                                                           ║
║b ║                                                           ║
║a ║                                                           ║
║r ║                                                           ║
║  ║                                                           ║
╚══╩═══════════════════════════════════════════════════════════╝
```

**Sidebar (280px, slide-in/out animado):**
```
╔═══════════════╗
║ Generic DB    ║  ← Sidebar header
║ Demo Suite    ║
╠═══════════════╣
║ ◈ Connection  ║  ← Menu item (active = highlight azul)
║ ⇄ Connector   ║
║ {} DataTypes  ║
║ ⊞ PagNav      ║
╚═══════════════╝
```

---

### 2.4 Seções (Frames)

#### 2.4.1 Frame: Connection

**Propósito:** Gerenciamento completo de conexões — criação, configuração, persistência e teste.

**Layout (2 painéis):**

```
╔═══════════════════════════╦═══════════════════════════════════╗
║ CONNECTION PARAMS          ║ CONFIG FILE / LOG                 ║
║                            ║                                   ║
║ Engine: [FireDAC       ▼]  ║ Format: [JSON ▼]                  ║
║ Driver: [SQLite        ▼]  ║                                   ║
║ Host:   [localhost      ]  ║ ┌─────────────────────────────┐   ║
║ Port:   [3306           ]  ║ │ {                           │   ║
║ DB:     [mydb           ]  ║ │   "engine": "FireDAC",      │   ║
║ User:   [root           ]  ║ │   "driver": "SQLite",       │   ║
║ Pass:   [••••••         ]  ║ │   ...                       │   ║
║ Schema: [public         ]  ║ │ }                           │   ║
║                            ║ └─────────────────────────────┘   ║
║ [Load Config] [Save Config] ║                                   ║
║ [Test Connection]           ║ ┌─────────────────────────────┐   ║
║                            ║ │ Connection Log               │   ║
║ Status: ● Connected         ║ │ [12:30] Connected OK        │   ║
╚═══════════════════════════╩═══════════════════════════════════╝
```

**Funcionalidades:**
- Seleção de Engine (FireDAC, dbExpress, ZeOS, UniDAC)
- Seleção de Driver (SQLite, MySQL, Firebird, Interbase, PostgreSQL, SQLServer, Oracle)
- Campos: Host, Port, Database/File, Username, Password, Schema
- Seletor de formato de config: JSON, YAML, XML, INI, TOML
- Preview do arquivo de configuração gerado (TMemo com syntax highlight básico)
- Load de arquivo de configuração nos formatos suportados
- Save de configuração para arquivo
- Test Connection com status visual e log
- Alternar entre engines mantendo parâmetros

---

#### 2.4.2 Frame: Connector

**Propósito:** Teste bidirecional entre conexão e componentes FMX via `TConnector`.

**Layout (sidebar de config + área de componentes):**

```
╔═══════════════╦══════════════════════════════════════════════╗
║ Query Config  ║  TComboBox      TEdit          TComboEdit    ║
║               ║  [Alagoas   ▼]  [Amazonas   ] [Ceará     ▼] ║
║ Engine:[▼]    ║                                              ║
║ Driver:[▼]    ║  TListBox (com SearchBox)   TListView        ║
║ SQL:          ║  🔍 Search...               🔍 Search...     ║
║ [select...]   ║  Acre                       Col1 | Col2      ║
║               ║  Alagoas                    ─────────────    ║
║ Filter JSON:  ║  Amazonas        ...         val1 | val2     ║
║ [{"Index":1}] ║                                              ║
║               ║  TStringGrid                TGrid            ║
║ IndexField:[▼]║  Cod | Estado | Sig         Cod | Estado     ║
║ ValueField:[▼]║  ─────────────────         ─────────────     ║
║ Options:  [▼] ║  1   | Acre   | AC          1   | Acre       ║
║               ║                                              ║
║ [Run]         ║                                              ║
╚═══════════════╩══════════════════════════════════════════════╝
```

**Funcionalidades:**
- Config: Engine, Driver, SQL, IndexField, ValueField, Filter JSON
- Binding automático para todos os 7 componentes simultaneamente
- Seletor de ConnectorOptions (Integer, JSON, Dictionary)
- Exibição do resultado em todos os componentes suportados
- Alternância entre engines em tempo de execução

---

#### 2.4.3 Frame: DataTypes

**Propósito:** Teste massivo de todos os tipos de dados do projeto.

**Sub-tabs:**
1. **Arrays** — TArrayString, TArrayVariant, TArrayField, TArrayAssoc
2. **Floats** — Formatação (Explicit/Implicit) e cálculos
3. **DateTime** — TTimeDate, TLocaleTimeDate
4. **Strings** — Type.String helpers

**Tab Arrays:**
```
╔═══════════════════════════════════════════════════════════╗
║ TArrayString    TArrayVariant    TArrayField              ║
║ [Fetch      ▼]  [Clone      ▼]  [ToJSON     ▼]          ║
║                                                           ║
║ ┌─────────────────────────────────────────────────────┐  ║
║ │ Result:                                             │  ║
║ │ key1 = value1                                       │  ║
║ │ key2 = value2                                       │  ║
║ └─────────────────────────────────────────────────────┘  ║
╚═══════════════════════════════════════════════════════════╝
```

---

#### 2.4.4 Frame: PagNav

**Propósito:** Teste visual de paginação e navegação conectada a dados reais.

**Layout:**
```
╔══════════════════════════════════════════════════════════╗
║ Connection: [Engine▼] [Driver▼]  [Connect]  [Query...]  ║
╠════════════════╦═══════════════════╦════════════════════╣
║   Original     ║     Minimal       ║       Full         ║
║                ║                   ║                    ║
║ [TBindNavigator]║ 🔍 Search...      ║ 🔍 Search...       ║
║ 🔍 Search...   ║ ┌──────────┐      ║ ┌──────────┐       ║
║ ┌──────────┐   ║ │  TGrid   │      ║ │  TGrid   │       ║
║ │  TGrid   │   ║ │          │      ║ │          │       ║
║ └──────────┘   ║ └──────────┘      ║ └──────────┘       ║
║                ║ [|<][<][>][>|]    ║ [|<][<][>][>|]     ║
║                ║                   ║ [+][-][✎][✓][✗][↺] ║
╚════════════════╩═══════════════════╩════════════════════╝
```

**Funcionalidades:**
- Conexão configurável (Engine + Driver) na barra superior
- 3 estilos de navegador: Original (TBindNavigator), Minimal (4 botões), Full (10 botões)
- Grids conectados a dados reais via TConnector
- Paginação funcional com página atual / total de páginas
- Futura evolução: filtros por coluna, ordenação, paginação server-side

---

### 2.5 Mapa de Migração AsIs → ToBe

| AsIs | ToBe | Observação |
|------|------|------------|
| GenericConnector (Button1/Button2) | Frame.Connector | Parametrizado, sem hardcode |
| GenericConnector (TabDBXxxClick) | Frame.Connection + Frame.Connector | Separação de responsabilidades |
| GenericDataTypes (TabArrays) | Frame.DataTypes → Tab Arrays | Mantido |
| GenericDataTypes (TabFloats) | Frame.DataTypes → Tab Floats | Mantido |
| GenericDataTypes (TabStrings) | Frame.DataTypes → Tab Strings | **Implementar** |
| GenericDataTypes (TabDateTime) | Frame.DataTypes → Tab DateTime | **Implementar** |
| GenericPagNav | Frame.PagNav | Com conexão real |
| GenericQueryBuilder | Frame.Connector (SQL editor) | QueryBuilder integrado |
| — | Frame.Connection (novo) | Config completa de conexão |

---

### 2.6 Dependências Mantidas

Todas as dependências existentes são mantidas:

```json
{
  "FastMM5": "memory management",
  "XSuperObject": "JSON parser",
  "ZeOS": "ZeOS engine adapter",
  "Neslib.Yaml": "YAML config support",
  "DelphiTOML": "TOML config support",
  "DotEnv4Delphi": ".env file support"
}
```

---

### 2.7 Roadmap Pós-ToBe

| Prioridade | Feature |
|-----------|---------|
| P1 | PagNav com paginação server-side |
| P1 | Frame.Connection — load/save de configurações |
| P2 | DataTypes — Strings e DateTime implementados |
| P2 | QueryBuilder visual integrado ao Frame.Connector |
| P3 | Componente Datatables (sort + filter + paginate) |
| P3 | Suporte a múltiplas conexões simultâneas |
| P4 | Theme switcher (Dark/Light mode) |
| P4 | Export de resultados (CSV, JSON, XLSX) |
