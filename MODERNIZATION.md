# Análise e Plano de Modernização — Generic Database

> **Objetivo:** Eliminar todos os arquivos `*.inc` de `Source\Connection` e `Source\Connector`,
> substituindo a seleção em tempo de compilação (`{$IFDEF}`) por uma arquitetura orientada a
> interfaces e padrões de projeto que permita a **troca de engine em runtime** sem recompilar,
> com suporte a múltiplas conexões simultâneas, interface fluente (chainable), parâmetros
> adicionais livres, criação via múltiplos formatos de configuração e suporte nativo a
> dbExpress, FireDAC, ZeOS e UniDAC desde o início.

> **Glossário de termos:**
> - **Engine** — biblioteca de acesso a dados (dbExpress, FireDAC, ZeOS, UniDAC). Substitui
>   o termo "framework" para evitar ambiguidade com o próprio Delphi RTL/FMX.
> - **Driver** — tipo de banco de dados (SQLite, MySQL, Firebird, etc.).
> - **Adapter** — implementação concreta de uma engine sob um contrato de interface.

---

## 1. Diagnóstico — Estado Atual

### 1.1 Mecanismo de seleção de engine

O projeto seleciona a engine de banco de dados **exclusivamente em tempo de compilação**
através de uma cadeia de arquivos `.inc`:

```
CNX.Consts.inc          ← ponto de entrada: {$DEFINE dbExpress / ZeOS / FireDAC}
  └─ CNX.Settings.inc   ← mapeia para símbolos internos (dbExpressLib, ZeOSLib, FireDACLib)
       └─ CNX.Params.inc / CNX.Helper.inc
            └─ Engines/CNX.dbExpress.inc
            └─ Engines/CNX.FireDAC.inc
            └─ Engines/CNX.ZeOS.inc
```

Consequência direta: **um binário compilado suporta exatamente uma engine**. Trocar de
dbExpress para FireDAC exige editar `CNX.Consts.inc`, recompilar e redistribuir.

### 1.2 Dependências de tipo embutidas via `.inc`

| Arquivo `.inc`          | Resolve para (dbExpress)  | Resolve para (FireDAC)  | Resolve para (ZeOS) |
|-------------------------|---------------------------|-------------------------|---------------------|
| `CNX.Type.inc`          | `TSQLConnection`          | `TFDConnection`         | `TZConnection`      |
| `CNX.Query.Type.inc`    | `TSQLQuery`               | `TFDQuery`              | `TZQuery`           |
| `CNX.DataSet.Type.inc`  | `TClientDataSet`          | `TFDMemTable`           | `TClientDataSet`    |
| `CNC.Type.inc`          | `TClientDataSet`          | `TFDMemTable`           | `TClientDataSet`    |

Cada tipo resolvido vaza para a assinatura pública de `IConnection`, `TQuery`, `TConnector` e
dos helpers — impossibilitando polimorfismo real.

### 1.3 Ifdef espalhados no código de negócio

`Connection.pas`, `Query.pas`, `Connector.pas` e os três `Options*.pas` contêm blocos
`{$IFDEF}` dentro de métodos de negócio (`StartTransaction`, `Commit`, `Rollback`,
`EnsureConnection`, `ToDataSet`, `Open`). Isso viola o Princípio Aberto/Fechado: adicionar
uma nova engine exige modificar os arquivos existentes.

### 1.4 Problema central — impossibilidade de troca em runtime

```delphi
// Hoje: seleção estática, impossível variar em runtime
FConnection := {$I CNX.Type.inc}.Create(nil);  // TSQLConnection, TFDConnection ou TZConnection
{$I CNX.Params.inc}                             // configura params para a engine escolhida
```

Não existe caminho para criar uma `TFDConnection` e uma `TSQLConnection` no mesmo binário e
escolher entre elas dinamicamente.

### 1.5 Inventário completo de `.inc` a eliminar

**`Source\Connection\`**
- `CNX.Consts.inc` — define o `{$DEFINE}` ativo
- `CNX.Settings.inc` — mapeia defines para símbolos de lib
- `CNX.Default.inc` — inclui os dois anteriores
- `CNX.Type.inc` — resolve tipo da conexão
- `CNX.Query.Type.inc` — resolve tipo da query
- `CNX.DataSet.Type.inc` — resolve tipo do dataset em memória
- `CNX.Params.inc` — inclui o `.inc` da engine ativa
- `CNX.Helper.inc` — idem para helpers
- `Frameworks/CNX.dbExpress.inc` — configuração dbExpress por driver
- `Frameworks/CNX.FireDAC.inc` — configuração FireDAC por driver
- `Frameworks/CNX.ZeOS.inc` — configuração ZeOS por driver

**`Source\Connector\`**
- `CNC.Default.inc` — reexporta `CNX.Default.inc`
- `CNC.Type.inc` — resolve tipo do dataset em memória

**`Source\Helpers\FMX.Grid\` e `Source\Helpers\FMX.StringGrid\`**
- `CNC.Default.inc` / `CNC.Type.inc` — dependências de tipo que vazam até os helpers de UI

### 1.6 Decisões sobre drivers específicos do dbExpress

Durante a análise dos arquivos `.inc` existentes foram identificadas duas situações que
impactam a camada dbExpress na nova arquitetura:

| Driver | Situação atual | Decisão |
|--------|---------------|---------|
| **Oracle** via dbExpress | Dois modos: driver nativo `dbxora.dll` + `oci.dll` **e** Devart `dbexpoda41.dll` | **Descontinuar Devart.** Manter apenas o driver nativo Oracle (`dbxora.dll`). Simplifica dependências e evita licença comercial adicional. |
| **PostgreSQL** via dbExpress | Dois modos: Devart `dbexppgsql40.dll` **e** ODBC genérico | **Descontinuar ODBC.** Manter apenas Devart. O driver nativo oficial do dbExpress para PostgreSQL não oferece alternativa viável; o ODBC traz limitações de metadados, tipos e performance. |

---

## 2. Arquitetura Proposta

### 2.1 Visão geral dos padrões

| Camada | Padrão | Função |
|---|---|---|
| Abstração de engine | **Strategy** | Cada engine é uma estratégia intercambiável |
| Ponto de entrada único | **Facade** | `TConnection` continua sendo a interface pública |
| Interface fluente | **Fluent/Builder** | Métodos chainable retornam `Self` — sem variáveis intermediárias |
| Criação de adapters | **Abstract Factory** | `IEngineFactory` instancia objetos da engine certa |
| Registro dinâmico | **Registry** | Permite registrar novas engines sem alterar código existente |
| Generics | `TQuery<TDataSet>` | Desacopla o tipo do dataset da camada de negócio |
| Ciclo de vida | **Smart Pointer** | `TSmartPointer<T>` / `ISmartPointer<T>` — units `SmartPointer.TSmartPointer` e `SmartPointer.ISmartPointer` (ver §5.3) |

### 2.2 Diagrama de camadas

```
┌─────────────────────────────────────────────────────────────────┐
│                        CAMADA DE APLICAÇÃO                      │
│   Demo\GenericConnectorForm.pas  (casos de uso — sem mudança)   │
└────────────────────────────┬────────────────────────────────────┘
                             │ usa
┌────────────────────────────▼────────────────────────────────────┐
│                     FACADE  (API pública)                       │
│  TConnection  ·  TQuery  ·  TConnector  ·  TQueryBuilder        │
│  (mesmos nomes, mesma interface pública — sem quebra de API)    │
└──────┬─────────────────────┬───────────────────────────────────┘
       │ delega              │ delega
┌──────▼──────────────────────▼─────────────────────────────────┐
│           IConnectionStrategy  ·  IQueryStrategy               │
│                   (interfaces)                                  │
└──────────────────────┬────────────────────────────────────────┘
                       │ implementado por
┌──────────────────────▼────────────────────────────────────────┐
│             ADAPTERS  (um por engine)                          │
│  dbExpress.ConnectionStrategy  ·  dbExpress.QueryStrategy      │
│  FireDAC.ConnectionStrategy    ·  FireDAC.QueryStrategy        │
│  ZeOS.ConnectionStrategy       ·  ZeOS.QueryStrategy           │
│  UniDAC.ConnectionStrategy     ·  UniDAC.QueryStrategy         │
└──────────────────────┬────────────────────────────────────────┘
                       │ criados por
┌──────────────────────▼────────────────────────────────────────┐
│              ENGINE REGISTRY / FACTORY                         │
│  TEngineRegistry.Register(TEngine.FireDAC, TFireDACFactory)    │
│  TEngineRegistry.Get(TEngine.UniDAC).CreateConnection          │
└───────────────────────────────────────────────────────────────┘
```

### 2.3 Enum `TEngine` e `TDriver`

```delphi
// TEngine — identifica a biblioteca de acesso a dados
// Chave do TEngineRegistry; detectado pelo compilador (sem strings mágicas)
TEngine = (FireDAC, dbExpress, ZeOS, UniDAC);

// TDriver — identifica o banco de dados
// Mantido exatamente como no projeto atual
TDriver = (SQLite, MySQL, Firebird, Interbase, MSSQL, PostgreSQL, Oracle);
```

O `TEngineRegistry` usa `TEngine` como chave do dicionário interno:

```delphi
TEngineRegistry = class
strict private
  class var FEngines:       TDictionary<TEngine, IEngineFactory>;
  class var FDefaultEngine: TEngine;
public
  class procedure Register(const AEngine: TEngine; const AFactory: IEngineFactory);
  class function  Get(const AEngine: TEngine): IEngineFactory;
  class function  Available: TArray<TEngine>;
  class function  DefaultEngine: TEngine;
  class procedure SetDefaultEngine(const AEngine: TEngine);
end;
```

### 2.4 Interfaces centrais

```delphi
// ============================================================
//  Contratos de Strategy
// ============================================================

IConnectionStrategy = interface
  ['{A1B2C3D4-0001-0000-0000-000000000001}']
  procedure Configure(const ADriver: TDriver; const AParams: TConnectionParams);
  procedure Connect;
  procedure Disconnect;
  function  IsConnected: Boolean;
  procedure StartTransaction;
  procedure Commit;
  procedure Rollback;
  function  NativeConnection: TObject;
end;

IQueryStrategy = interface
  ['{A1B2C3D4-0001-0000-0000-000000000002}']
  procedure SetConnection(const AStrategy: IConnectionStrategy);
  procedure Open(const ASQL: String);
  procedure ExecSQL(const ASQL: String);
  function  IsEmpty: Boolean;
  function  EOF: Boolean;
  procedure First;
  procedure Next;
  function  Fields: TFields;
  function  AsDataSet: TDataSet;
  function  AsInMemoryDataSet: TDataSet;
end;

IEngineFactory = interface
  ['{A1B2C3D4-0001-0000-0000-000000000003}']
  function Engine: TEngine;
  function CreateConnectionStrategy: IConnectionStrategy;
  function CreateQueryStrategy: IQueryStrategy;
end;

IDriverConfigurator = interface
  ['{A1B2C3D4-0001-0000-0000-000000000004}']
  procedure Configure(const AConn: TObject; const AParams: TConnectionParams);
  function  DriverName: TDriver;
end;

// ============================================================
//  Record de parâmetros de conexão
// ============================================================
TConnectionParams = record
  Driver:    TDriver;
  Host:      String;
  Port:      Integer;
  Schema:    String;
  Database:  String;
  Username:  String;
  Password:  String;
  // Parâmetros adicionais livres — CharacterSet, lc_ctype, Compress, Pooled, etc.
  ExtraArgs: TDictionary<String, String>;
  class function Default: TConnectionParams; static;
end;
```

### 2.5 Facade `TConnection` — API pública preservada e estendida

```delphi
TConnection = class(TInterfacedObject, IConnection)
private
  FEngine:   TEngine;
  FStrategy: IConnectionStrategy;
  FParams:   TConnectionParams;
  class var FInstance: IConnection;
  procedure ApplyEngine(const AEngine: TEngine);
public
  // ── Construtores ────────────────────────────────────────────
  // Sem argumento: usa TEngineRegistry.DefaultEngine
  constructor Create; overload;
  // Com Engine enum: define a engine diretamente
  constructor Create(const AEngine: TEngine); overload;

  // ── Propriedade Engine ──────────────────────────────────────
  // Prioridade sobre o construtor.
  // Antes de Connected: apenas reconfigura a estratégia interna.
  // Após Connected: equivalente a SwitchEngine (desconecta e reconecta).
  property Engine: TEngine read FEngine write SetEngine;

  // ── Troca de engine em runtime ───────────────────────────────
  function SwitchEngine(const AEngine: TEngine): TConnection;

  // ── API existente preservada ─────────────────────────────────
  property Driver:    TDriver  read GetDriver   write SetDriver;
  property Host:      String   read GetHost     write SetHost;
  property Port:      Integer  read GetPort     write SetPort;
  property Schema:    String   read GetSchema   write SetSchema;
  property Database:  String   read GetDatabase write SetDatabase;
  property Username:  String   read GetUsername write SetUsername;
  property Password:  String   read GetPassword write SetPassword;
  property Connected: Boolean  read GetConnected write SetConnected;
  property Connect:   Boolean  write SetConnect;
  procedure StartTransaction;
  procedure Commit;
  procedure Rollback;
  function  CheckDatabase: Boolean;
  function  Connection: TObject;

  // ── Interface Fluente (Chainable) ────────────────────────────
  function WithEngine(const AEngine: TEngine): TConnection;
  function WithDriver(const ADriver: TDriver): TConnection;
  function WithHost(const AHost: String): TConnection;
  function WithPort(const APort: Integer): TConnection;
  function WithSchema(const ASchema: String): TConnection;
  function WithDatabase(const ADatabase: String): TConnection;
  function WithUsername(const AUsername: String): TConnection;
  function WithPassword(const APassword: String): TConnection;

  // ── Parâmetros Adicionais Livres ─────────────────────────────
  function AddArgument(const AKey, AValue: String): TConnection;
  function AddParameter(const AKey, AValue: String): TConnection; // alias de AddArgument

  // ── Criação a partir de arquivos de configuração ─────────────
  class function CreateFromJSON(const ASource: String): TConnection;
  class function CreateFromINI (const ASource: String): TConnection;
  class function CreateFromXML (const ASource: String): TConnection;
  class function CreateFromYAML(const ASource: String): TConnection;
  class function CreateFromNEON(const ASource: String): TConnection;
  class function CreateFromTOML(const ASource: String): TConnection;
end;
```

#### Regra de prioridade Engine

| Situação | Comportamento |
|---|---|
| `TConnection.Create` | Usa `TEngineRegistry.DefaultEngine` |
| `TConnection.Create(FireDAC)` | Engine = FireDAC |
| `Conn.Engine := ZeOS` antes de `Connected` | Reconfigura estratégia — sem desconectar |
| `Conn.Engine := ZeOS` após `Connected` | Desconecta, troca estratégia, mantém params |
| `WithEngine(UniDAC)` (chainable) | Equivalente a atribuir `Engine` — retorna `Self` |

### 2.6 Interface Fluente — prefixo `With`

Os métodos chainable adotam o prefixo `With` como convenção Delphi para interfaces fluentes.

**Por que `With` e não sem prefixo?**

Em Delphi, `property` setters são `procedure` — não retornam valor. Portanto não é possível
escrever `Conn.Driver(MySQL).Host('localhost')` e ao mesmo tempo manter `Conn.Driver := MySQL`
como property — os dois entrariam em conflito de nome no mesmo escopo da classe. O prefixo
`With` resolve essa ambiguidade de forma limpa, é a convenção adotada pela RTL e por
bibliotecas populares do ecossistema Delphi (Spring4D, Sparkle, etc.), e deixa claro visualmente
que o método retorna `Self`. As duas formas coexistem sem quebra:

```delphi
// Estilo clássico com property (retrocompatível — sem qualquer quebra)
DB := TConnection.Create(FireDAC);
DB.Driver    := MySQL;
DB.Host      := 'localhost';
DB.Database  := 'app';
DB.Username  := 'root';
DB.Password  := 'senha';
DB.Connected := True;

// Estilo chainable com With (novo)
DB := TConnection.Create
        .WithEngine(FireDAC)
        .WithDriver(MySQL)
        .WithHost('localhost')
        .WithDatabase('app')
        .WithUsername('root')
        .WithPassword('senha');
DB.Connected := True;

// Chainable com parâmetros extras e criação de query em sequência
DB := TConnection.Create(FireDAC)
        .WithDriver(PostgreSQL)
        .WithHost('pghost').WithPort(5432)
        .WithSchema('public').WithDatabase('erp')
        .WithUsername('pguser').WithPassword('s3cr3t')
        .AddArgument('CharacterSet', 'UTF8')
        .AddArgument('lc_ctype', 'pt_BR.UTF-8');
DB.Connected := True;
```

### 2.7 Parâmetros Adicionais — `AddArgument` / `AddParameter`

Substituem toda a configuração hardcoded nos arquivos `.inc` para parâmetros específicos
de driver ou engine que não fazem parte dos campos padrão.

```delphi
// MySQL — charset e compressão
Conn.AddArgument('CharacterSet', 'UTF8')
    .AddArgument('Compress',     'True');

// Firebird — dialeto e charset
Conn.AddArgument('SQLDialect',   '3')
    .AddArgument('CharacterSet', 'UTF8');

// PostgreSQL — search_path e locale
Conn.AddArgument('lc_ctype',    'pt_BR.UTF-8')
    .AddArgument('search_path', 'public,relatorio');

// Oracle — charset e NLS
Conn.AddArgument('CharacterSet',  'UTF8')
    .AddArgument('NLS_LANGUAGE',  'BRAZILIAN PORTUGUESE');

// SQLite — modo de journaling
Conn.AddArgument('JournalMode',  'WAL')
    .AddArgument('Synchronous',  'NORMAL');

// Parâmetros de pool (FireDAC)
Conn.AddArgument('Pooled',        'True')
    .AddArgument('Pool_MaxItems', '10');
```

`AddArgument` e `AddParameter` são aliases — semântica idêntica, o consumidor escolhe
a nomenclatura de sua preferência. Chamar duas vezes com a mesma chave sobrescreve o valor.
Cada adapter aplica os argumentos que reconhece e ignora os demais sem erro.

### 2.8 Criação via arquivos de configuração

Todos os construtores de formato recebem o **conteúdo** do arquivo (já lido) como `String`
ou um caminho de arquivo. Internamente desserializam para `TConnectionParams` e delegam ao
construtor `Create(AEngine)`.

```delphi
// JSON
DB := TConnection.CreateFromJSON('{"engine":"FireDAC","driver":"MySQL","host":"localhost",...}');

// INI
// [Connection]
// Engine=FireDAC
// Driver=MySQL
// Host=localhost
// Port=3306
// Database=app
// Username=root
// Password=senha
// [Args]
// CharacterSet=UTF8
DB := TConnection.CreateFromINI(TFile.ReadAllText('conn.ini'));

// XML
// <Connection>
//   <Engine>FireDAC</Engine>
//   <Driver>PostgreSQL</Driver>
//   <Host>pghost</Host>
//   <Args><CharacterSet>UTF8</CharacterSet></Args>
// </Connection>
DB := TConnection.CreateFromXML(TFile.ReadAllText('conn.xml'));

// YAML
// engine: ZeOS
// driver: MySQL
// host: localhost
// args:
//   CharacterSet: UTF8
DB := TConnection.CreateFromYAML(TFile.ReadAllText('conn.yaml'));

// NEON (Object Pascal Serialization — biblioteca Neon para Delphi)
// Mesmo formato JSON/estrutura; usa TNeonDeserializer internamente
DB := TConnection.CreateFromNEON(TFile.ReadAllText('conn.neon.json'));

// TOML
// engine = "UniDAC"
// driver = "Oracle"
// host   = "orahost"
// port   = 1521
// [args]
// CharacterSet = "UTF8"
DB := TConnection.CreateFromTOML(TFile.ReadAllText('conn.toml'));
```

**Dependências de desserialização:**

| Método | Dependência | Inclusa na RTL |
|--------|-------------|---------------|
| `CreateFromJSON` | `System.JSON` | Sim |
| `CreateFromINI`  | `System.IniFiles` | Sim |
| `CreateFromXML`  | `Xml.XMLDoc`, `Xml.XMLIntf` | Sim |
| `CreateFromYAML` | Biblioteca YAML para Delphi (ex: `Neslib.Yaml`) | Não — opcional |
| `CreateFromNEON` | Biblioteca Neon (`Neon.Core.*`) | Não — opcional |
| `CreateFromTOML` | Biblioteca TOML para Delphi | Não — opcional |

Os métodos que dependem de bibliotecas opcionais são compilados somente se a biblioteca
estiver no search path (`{$IF Declared(TNeonDeserializer)}`), evitando erro de compilação
para quem não usa esses formatos.

### 2.9 Estrutura de arquivos dos Adapters

Nomenclatura sem abreviações — nome completo da engine em todos os arquivos.

```
Source\
  Connection\
    Connection.pas                    ← Facade, zero {$IFDEF} de engine
    Query.pas                         ← Facade genérico, zero {$IFDEF}
    QueryBuilder.pas                  ← inalterado
    Params\
      ConnectionParams.pas            ← TConnectionParams com ExtraArgs
    Strategy\
      IConnectionStrategy.pas
      IQueryStrategy.pas
      IEngineFactory.pas
      IDriverConfigurator.pas
    Adapters\
      dbExpress\
        dbExpress.ConnectionStrategy.pas
        dbExpress.QueryStrategy.pas
        dbExpress.Factory.pas               ← registra TEngine.dbExpress
        dbExpress.Drivers\
          dbExpress.Driver.SQLite.pas
          dbExpress.Driver.MySQL.pas
          dbExpress.Driver.Firebird.pas
          dbExpress.Driver.Interbase.pas
          dbExpress.Driver.MSSQL.pas
          dbExpress.Driver.PostgreSQL.pas   ← usa Devart (dbexppgsql40.dll)
          dbExpress.Driver.Oracle.pas       ← usa driver nativo (dbxora.dll + oci.dll)
      FireDAC\
        FireDAC.ConnectionStrategy.pas
        FireDAC.QueryStrategy.pas
        FireDAC.Factory.pas                 ← registra TEngine.FireDAC
        FireDAC.Drivers\
          FireDAC.Driver.SQLite.pas
          FireDAC.Driver.MySQL.pas
          FireDAC.Driver.Firebird.pas
          FireDAC.Driver.Interbase.pas
          FireDAC.Driver.MSSQL.pas
          FireDAC.Driver.PostgreSQL.pas
          FireDAC.Driver.Oracle.pas
      ZeOS\
        ZeOS.ConnectionStrategy.pas
        ZeOS.QueryStrategy.pas
        ZeOS.Factory.pas                    ← registra TEngine.ZeOS
        ZeOS.Drivers\
          ZeOS.Driver.SQLite.pas
          ZeOS.Driver.MySQL.pas
          ZeOS.Driver.Firebird.pas
          ZeOS.Driver.Interbase.pas
          ZeOS.Driver.MSSQL.pas
          ZeOS.Driver.PostgreSQL.pas
          ZeOS.Driver.Oracle.pas
      UniDAC\
        UniDAC.ConnectionStrategy.pas
        UniDAC.QueryStrategy.pas
        UniDAC.Factory.pas                  ← registra TEngine.UniDAC
        UniDAC.Drivers\
          UniDAC.Driver.SQLite.pas
          UniDAC.Driver.MySQL.pas
          UniDAC.Driver.Firebird.pas
          UniDAC.Driver.Interbase.pas
          UniDAC.Driver.MSSQL.pas
          UniDAC.Driver.PostgreSQL.pas
          UniDAC.Driver.Oracle.pas
    Registry\
      EngineRegistry.pas
    Config\
      Connection.Config.JSON.pas
      Connection.Config.INI.pas
      Connection.Config.XML.pas
      Connection.Config.YAML.pas
      Connection.Config.NEON.pas
      Connection.Config.TOML.pas
```

### 2.10 Adicionar uma quinta engine futura

```delphi
// 1. Adicionar valor ao enum TEngine (único ponto de mudança obrigatório):
TEngine = (FireDAC, dbExpress, ZeOS, UniDAC, mORMot);

// 2. Criar os arquivos em Source\Connection\Adapters\mORMot\
//    mORMot.ConnectionStrategy.pas
//    mORMot.QueryStrategy.pas
//    mORMot.Factory.pas
//    mORMot.Drivers\mORMot.Driver.*.pas

// 3. Em mORMot.Factory.pas — auto-registro:
initialization
  TEngineRegistry.Register(TEngine.mORMot, TmORMotFactory.Create);

// Nenhum outro arquivo precisa ser modificado — OCP cumprido.
```

### 2.11 Suporte UniDAC — mapeamento de drivers

| `TDriver`   | UniDAC `ProviderName` | Observação |
|-------------|----------------------|------------|
| SQLite      | `SQLite`             | —          |
| MySQL       | `MySQL`              | —          |
| Firebird    | `InterBase`          | Provider unificado |
| Interbase   | `InterBase`          | Provider unificado |
| MSSQL       | `SQL Server`         | —          |
| PostgreSQL  | `PostgreSQL`         | —          |
| Oracle      | `Oracle`             | —          |

UniDAC usa `TUniConnection` com `ProviderName` diferente por banco. Parâmetros específicos
do provider são passados via `SpecificOptions` — propagados automaticamente pelo
`UniDAC.Driver.*.pas` correspondente, com suporte a `ExtraArgs`.

---

## 3. Troca de Engine em Runtime

### 3.1 Construtores e propriedade `Engine`

```delphi
// Forma 1 — construtor com Engine enum
Conn1 := TConnection.Create(FireDAC);
Conn1.Driver    := PostgreSQL;
Conn1.Connected := True;

// Forma 2 — construtor padrão + propriedade Engine (prioridade da propriedade)
Conn2 := TConnection.Create;
Conn2.Engine := ZeOS;
Conn2.Driver := MySQL;
Conn2.Connected := True;

// Forma 3 — chainable completo
Conn3 := TConnection.Create(UniDAC)
           .WithDriver(Oracle)
           .WithHost('orahost').WithPort(1521)
           .WithSchema('HR').WithUsername('hr').WithPassword('oracle')
           .AddArgument('CharacterSet', 'UTF8');
Conn3.Connected := True;
```

### 3.2 Troca em runtime via `SwitchEngine` ou propriedade `Engine`

```delphi
DB := TConnection.Create(FireDAC)
        .WithDriver(MySQL).WithHost('localhost')
        .WithDatabase('app').WithUsername('root').WithPassword('1234');
DB.Connected := True;

// Troca para dbExpress — params são preservados, apenas a estratégia muda
DB.SwitchEngine(dbExpress);
DB.Connected := True;

// Ou via propriedade (comportamento equivalente após Connected)
DB.Engine := ZeOS;
DB.Connected := True;
```

### 3.3 Troca via configuração externa

```delphi
// Configuração carregada de arquivo — engine definida pelo arquivo
DB := TConnection.CreateFromJSON(TFile.ReadAllText('settings.json'));
DB.Connected := True;

// Troca de engine mantendo os demais params via configuração INI
DB := TConnection.CreateFromINI(TFile.ReadAllText('conn.ini'));
DB.Engine := FireDAC;  // sobrescreve a engine do arquivo se necessário
DB.Connected := True;
```

### 3.4 Múltiplas conexões simultâneas

```delphi
var
  Conn1: TConnection;  // FireDAC → PostgreSQL
  Conn2: TConnection;  // ZeOS → MySQL
  Conn3: TConnection;  // UniDAC → Oracle

Conn1 := TConnection.Create(FireDAC)
           .WithDriver(PostgreSQL).WithHost('pghost').WithPort(5432)
           .WithDatabase('analytics').WithUsername('pguser').WithPassword('s3cr3t')
           .AddArgument('CharacterSet', 'UTF8');

Conn2 := TConnection.Create(ZeOS)
           .WithDriver(MySQL).WithHost('mysqlhost').WithPort(3306)
           .WithDatabase('app').WithUsername('appuser').WithPassword('pass');

Conn3 := TConnection.Create(UniDAC)
           .WithDriver(Oracle).WithHost('orahost').WithPort(1521)
           .WithSchema('HR').WithUsername('hr').WithPassword('oracle')
           .AddArgument('CharacterSet', 'UTF8');

Conn1.Connected := True;
Conn2.Connected := True;
Conn3.Connected := True;

Q1 := TQuery.Create(Conn1);
Q2 := TQuery.Create(Conn2);
Q3 := TQuery.Create(Conn3);
```

> `TConnectionClass` (Singleton) é mantido como atalho opcional para código legado.

---

## 4. Configuração de Drivers — Substituindo os `.inc` de Engine

### 4.1 Atual — blocos `{$IFDEF}` em arquivo `.inc`

```pascal
// CNX.FireDAC.inc — mistura toda a configuração de todos os drivers num único arquivo
{$IFDEF MySQL}
  FConnection.Params.DriverID := 'MySQL';
  FConnection.Params.Server   := FHost;
{$ENDIF}
{$IFDEF PostgreSQL}
  ...
{$ENDIF}
```

### 4.2 Proposto — `IDriverConfigurator` por engine/driver

```delphi
// Um class por combinação engine+driver
TFireDAC_MySQLConfigurator = class(TInterfacedObject, IDriverConfigurator)
  procedure Configure(const AConn: TObject; const AParams: TConnectionParams);
  begin
    var Conn := AConn as TFDConnection;
    Conn.Params.DriverID  := 'MySQL';
    Conn.Params.Server    := AParams.Host;
    Conn.Params.Port      := AParams.Port;
    Conn.Params.Database  := AParams.Database;
    Conn.Params.UserName  := AParams.Username;
    Conn.Params.Password  := AParams.Password;
    // ExtraArgs conhecidos
    if AParams.ExtraArgs.ContainsKey('CharacterSet') then
      Conn.Params.Values['CharacterSet'] := AParams.ExtraArgs['CharacterSet'];
    if AParams.ExtraArgs.ContainsKey('Compress') then
      Conn.Params.Values['Compress'] := AParams.ExtraArgs['Compress'];
  end;
  function DriverName: TDriver; begin Result := MySQL; end;
end;
```

Cada `ConnectionStrategy` mantém um `TDictionary<TDriver, IDriverConfigurator>` e
delega ao configurador correto — sem `case` ou `{$IFDEF}`.

### 4.3 Mapeamento dbExpress — decisões de driver

| Driver | Biblioteca | Observação |
|--------|-----------|------------|
| SQLite | `Data.DBXSqlite` | RTL nativa |
| MySQL | `Data.DBXMySql` + `dbxmys.dll` | RTL nativa |
| Firebird | `Data.DBXFirebird` + `fbclient.dll` | RTL nativa |
| Interbase | `Data.DBXInterBase` + `ibclient.dll` | RTL nativa |
| MSSQL | `Data.DBXMSSQL` + `sqlncli11.dll` | RTL nativa |
| PostgreSQL | `DBXDevartPostgreSQL` + `dbexppgsql40.dll` | **Devart — único viável** |
| Oracle | `Data.DBXOracle` + `dbxora.dll` + `oci.dll` | **Nativo — Devart descontinuado** |

---

## 5. Camada Connector — Preservando `TConnector`, `OptionsJSON`, `OptionsInteger`, `OptionsArray`

### 5.1 Solução — `AsInMemoryDataSet: TDataSet`

A interface `IQueryStrategy` expõe `AsInMemoryDataSet: TDataSet`. Internamente:
- `dbExpress.QueryStrategy` → `TClientDataSet` via `TDataSetProvider`
- `FireDAC.QueryStrategy` → `TFDMemTable` via `CopyDataSet`
- `ZeOS.QueryStrategy` → `TClientDataSet` (mesmo mecanismo do dbExpress)
- `UniDAC.QueryStrategy` → `TClientDataSet` (UniDAC suporte nativo a CDS)

O `TConnector` opera sempre sobre `TDataSet` — zero `{$IFDEF}`.

```delphi
// Antes (com .inc):
function TConnector.ToDataSet: {$I CNC.Type.inc};

// Depois (sem .inc):
function TConnector.ToDataSet: TDataSet;
```

### 5.2 `OptionsJSON`, `OptionsInteger`, `OptionsArray` — sem alteração de API

Mesmo contrato público. Mudança interna: substituir `TClientDataSet`/`TFDMemTable` por
`TDataSet` e chamar `FQuery.Strategy.AsInMemoryDataSet`.

### 5.3 `Source\SmartPointer` — um tipo por unit (padrão `*.Intf` / implementação)

A API pública (`ISmartPointer<T>`, `TSmartPointer<T>`, operadores implícitos, propriedade `Ref`)
permanece a mesma. O que mudou é apenas o **layout físico**, alinhado a `Connection.Intf`,
`Query.Intf`, etc.:

| Unit | Conteúdo |
|------|----------|
| `SmartPointer.IGuard.Intf.pas` | `IGuard` |
| `SmartPointer.Guard.pas` | `TGuard` — `TInterfacedObject` que dá `Free` ao `TObject` no `Destroy` |
| `SmartPointer.ISmartPointer.pas` | record `ISmartPointer<T>` |
| `SmartPointer.RefGuard.pas` | `TSmartPointerRefGuard` — libera via `IInterface` quando o objeto suporta, senão `Free` |
| `SmartPointer.TSmartPointer.pas` | record `TSmartPointer<T>` |

**Ordem de compilação sugerida:** `SmartPointer.IGuard.Intf` → `SmartPointer.Guard` → `SmartPointer.ISmartPointer` → `SmartPointer.RefGuard` → `SmartPointer.TSmartPointer`.

Nos `uses` do código de aplicação, usar `SmartPointer.ISmartPointer` e/ou `SmartPointer.TSmartPointer`
(em vez dos antigos units `ISmartPointer` e `TSmartPointer`). Os drivers FireDAC que só precisam do
cast implícito para `ISmartPointer<T>` referenciam apenas `SmartPointer.ISmartPointer`.

---

## 6. Compatibilidade com Casos de Uso Existentes

```delphi
// Demo\GenericConnectorForm.pas — padrão atual preservado sem modificação
DBSQLite := TConnection.Create;
DBSQLite.Driver    := SQLite;
DBSQLite.Database  := '...';
DBSQLite.Connected := True;

SQL       := TQuery.Create;
SQL       := Query.View('SELECT id AS Codigo, nome AS Estado FROM estado');
Connector := TConnector.Create(SQL);
Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', 1);
Connector.ToGrid(GridSQLite, 3);
Connector.ToListView(ListViewSQLite, ['Codigo', 'Estado', 'Sigla'], 13);
```

| Elemento | Antes | Depois |
|---|---|---|
| `TConnection.Create` | cria objeto de engine via `.inc` | cria via `TEngineRegistry.Get(DefaultEngine)` |
| `TConnection.Create(FireDAC)` | não existia | cria estratégia via `TEngine` enum |
| `Conn.Engine := ZeOS` | não existia | reconfigura estratégia sem recriar o objeto |
| `Conn.WithDriver(MySQL)...` | não existia | interface fluente chainable |
| `Conn.AddArgument(...)` | hardcoded nos `.inc` | parâmetro livre propagado ao driver |
| `CreateFromJSON/INI/XML/YAML/NEON/TOML` | não existia | 6 construtores por formato |
| `TConnector.ToDataSet` | `TClientDataSet` ou `TFDMemTable` via `.inc` | `TDataSet` via `AsInMemoryDataSet` |
| Troca de engine | impossível sem recompilar | `Conn.Engine := FireDAC` ou `SwitchEngine` |
| Múltiplos engines simultâneos | impossível | `TConnection.Create(FireDAC)` + `TConnection.Create(UniDAC)` |

---

## 7. Plano de Implementação

### Fase 1 — Contratos (sem alterar nada existente)
- [x] Expandir `TEngine` com `UniDAC` em `Connection.pas`
- [x] Criar `Source\Connection\Params\ConnectionParams.pas` (com `ExtraArgs`)
- [x] Criar `Source\Connection\Strategy\IConnectionStrategy.pas`
- [x] Criar `Source\Connection\Strategy\IQueryStrategy.pas`
- [x] Criar `Source\Connection\Strategy\IEngineFactory.pas`
- [x] Criar `Source\Connection\Strategy\IDriverConfigurator.pas`
- [x] Criar `Source\Connection\Registry\EngineRegistry.pas` (chave `TEngine`)

### Fase 2 — Adapter FireDAC
- [x] `FireDAC.ConnectionStrategy.pas`
- [x] `FireDAC.QueryStrategy.pas`
- [x] `FireDAC.Drivers\FireDAC.Driver.*.pas` (7 drivers, com `ExtraArgs`)
- [x] `FireDAC.Factory.pas` — auto-registra `TEngine.FireDAC` em `initialization`
- [ ] Smoke test com Demo usando FireDAC

### Fase 3 — Adapter dbExpress
- [x] `dbExpress.ConnectionStrategy.pas`, `dbExpress.QueryStrategy.pas`
- [x] `dbExpress.Driver.PostgreSQL.pas` — Devart `dbexppgsql40.dll`
- [x] `dbExpress.Driver.Oracle.pas` — nativo `dbxora.dll` + `oci.dll` (sem Devart)
- [x] Demais `dbExpress.Driver.*.pas`
- [x] `dbExpress.Factory.pas` — auto-registra `TEngine.dbExpress`

### Fase 4 — Adapter ZeOS
- [x] `ZeOS.ConnectionStrategy.pas`, `ZeOS.QueryStrategy.pas`
- [x] `ZeOS.Drivers\ZeOS.Driver.*.pas`
- [x] `ZeOS.Factory.pas` — auto-registra `TEngine.ZeOS`

### Fase 5 — Adapter UniDAC
- [x] `UniDAC.ConnectionStrategy.pas` — wrap `TUniConnection`
- [x] `UniDAC.QueryStrategy.pas` — wrap `TUniQuery`
- [x] `UniDAC.Drivers\UniDAC.Driver.*.pas` (7 drivers com `ProviderName` + `SpecificOptions`)
- [x] `UniDAC.Factory.pas` — auto-registra `TEngine.UniDAC`

### Fase 6 — Refatorar `Connection.pas`
- [x] Remover todos `{$I ...}` e `{$IFDEF}` de engine
- [x] Implementar `FEngine`, `FParams`, `FStrategy: IConnectionStrategy`
- [x] Construtores `Create` e `Create(TEngine)`
- [x] Propriedade `Engine` com `SetEngine`
- [x] Métodos chainable `With*`
- [x] `AddArgument` / `AddParameter`
- [x] `SwitchEngine`
- [x] Manter `TConnectionClass` (Singleton opcional)

### Fase 7 — Construtores de configuração
- [x] `Source\Connection\Config\Connection.Config.JSON.pas`
- [x] `Source\Connection\Config\Connection.Config.INI.pas`
- [x] `Source\Connection\Config\Connection.Config.XML.pas`
- [ ] `Source\Connection\Config\Connection.Config.YAML.pas` (condicional — Neslib.Yaml)
- [ ] `Source\Connection\Config\Connection.Config.NEON.pas` (condicional — Neon)
- [ ] `Source\Connection\Config\Connection.Config.TOML.pas` (condicional — TOML lib)

### Fase 8 — Refatorar `Query.pas`
- [x] Remover `{$IFDEF}` de engine
- [x] `TQuery` usa `FStrategy: IQueryStrategy` injetada via `TConnection`

### Fase 9 — Refatorar `Connector.pas` e `Options*.pas`
- [x] Substituir `{$I CNC.Type.inc}` por `TDataSet`
- [x] `ToDataSet` retorna `TDataSet`
- [x] Remover imports condicionais de engines

### Fase 10 — Limpeza
- [x] Remover todos os `.inc` de `Source\Connection\` e `Source\Connector\`
- [x] Remover `CNC.Default.inc` e `CNC.Type.inc` dos helpers de Grid/StringGrid
- [x] Atualizar `uses` globalmente

### Fase 11 — Validação (estrutural ✓ — runtime pendente compilação no IDE)
- [ ] `Demo\GenericConnector` com FireDAC — resultado idêntico à versão atual
- [ ] Troca de engine em runtime demonstrada no formulário Demo
- [ ] Múltiplas conexões simultâneas (FireDAC + ZeOS + UniDAC) no mesmo processo
- [ ] `AddArgument('CharacterSet','UTF8')` propagado corretamente ao driver
- [ ] `CreateFromINI` e `CreateFromJSON` carregando conexão do arquivo
- [ ] Oracle via dbExpress com driver nativo (sem Devart)
- [ ] PostgreSQL via dbExpress com Devart
- [ ] Mock engine adicionado sem alterar nenhum arquivo existente

---

## 8. Regras de Implementação

1. **Nenhum `{$IFDEF}` de engine fora dos adapters.** Permitido apenas: `{$IFDEF MSWINDOWS}`,
   `{$IFDEF WIN64}`, `{$IF CompilerVersion >= ...}`.

2. **Nomes de arquivo sem abreviações.** `FireDAC.Factory.pas`, não `FDA.Factory.pas`.
   Sempre o nome completo da engine.

3. **`TEngine` enum como chave, nunca string.** O compilador detecta valores inválidos.

4. **Cada adapter em seu próprio unit com `uses` isolado.** `Connection.pas` não importa
   `FireDAC.*`, `Data.DBX*`, `Z*` nem `Uni*`.

5. **Registro automático via `initialization`.** Inclusão da unit no projeto = engine
   disponível em runtime.

6. **Prioridade da propriedade `Engine` sobre o construtor.**

7. **`AddArgument` é idempotente** — mesma chave duas vezes sobrescreve o valor anterior.

8. **`SwitchEngine` lança exceção se `InTransaction = True`.** Transações abertas impedem
   troca de engine.

9. **Métodos de configuração opcionais** (`CreateFromYAML`, `CreateFromNEON`,
   `CreateFromTOML`) compilam somente se a biblioteca de terceiros estiver no path.

10. **API pública estável.** `TConnection`, `TQuery`, `TConnector`, `TQueryBuilder`
    mantêm os mesmos nomes de métodos e propriedades existentes hoje.

11. **`TConnectionClass` (Singleton) preservado** — cria `TConnection` com
    `TEngineRegistry.DefaultEngine`.

12. **`TSmartPointer<T>` e `ISmartPointer<T>` inalterados na API.** A implementação foi
    fragmentada em `Source\SmartPointer\` conforme a tabela da §5.3; demos e `.dproj` listam
    os cinco units na ordem de dependência.

---

## 9. Riscos e Mitigações

| Risco | Impacto | Mitigação |
|---|---|---|
| `TFDMemTable` e `TClientDataSet` têm APIs diferentes | Médio | `AsInMemoryDataSet` retorna `TDataSet`; diferenças encapsuladas no adapter |
| dbExpress usa `TTransactionDesc` exclusivo | Baixo | Encapsulado em `dbExpress.ConnectionStrategy`; não vaza |
| FireDAC pool exige `ConnectionName` único | Baixo | Lógica de nome único movida para `FireDAC.ConnectionStrategy` |
| ZeOS `LibraryLocation` depende de plataforma | Baixo | Encapsulado em `ZeOS.Driver.*.pas` |
| `QueryHelper.pas` usa `{$IFDEF}` em `Open` | Baixo | `Open` em thread movido para `FireDAC.QueryStrategy.Open` |
| PostgreSQL dbExpress requer licença Devart | Médio | Documentado; unit Devart compilada condicionalmente |
| UniDAC requer licença comercial | Baixo | Adapter compilado apenas se `Uni.pas` estiver no path |
| `SwitchEngine` com transação aberta | Alto | Exceção explícita com mensagem clara |
| `ExtraArgs` com chave inválida | Baixo | Adapter ignora silenciosamente; log opcional via callback |
| Bibliotecas YAML/NEON/TOML ausentes | Baixo | Compilação condicional — sem erro se ausente |

---

## 10. Resumo Executivo

| Aspecto | Antes | Depois |
|---|---|---|
| Seleção de engine | Compilação (`{$DEFINE}`) | Runtime via `TEngine` enum |
| Identificação de engine | String literal ou `{$DEFINE}` | `TEngine` enum — type-safe |
| Troca de engine | Recompilar e redistribuir | `Conn.Engine := ZeOS` ou `SwitchEngine` |
| Múltiplas engines simultâneas | Impossível | `TConnection.Create(FireDAC)` + `TConnection.Create(UniDAC)` |
| Propriedade `Engine` | Não existia | Define/troca a engine com prioridade |
| Interface fluente | Não existia | `.WithDriver(MySQL).WithHost(...).AddArgument(...)` |
| Parâmetros extras | Hardcoded nos `.inc` | `AddArgument` / `AddParameter` |
| Configuração externa | Não existia | JSON, INI, XML, YAML, NEON, TOML |
| Adicionar nova engine | Modificar 6+ arquivos | Criar 3 units + `initialization` |
| Suporte a UniDAC | Não existia | Adapter completo incluído desde o início |
| Oracle dbExpress | Nativo + Devart (dois modos) | Apenas nativo (`dbxora.dll` + `oci.dll`) |
| PostgreSQL dbExpress | Devart + ODBC (dois modos) | Apenas Devart (`dbexppgsql40.dll`) |
| Nomes de arquivos | Abreviados (FDA, DBX, ZOS, UNI) | Nome completo da engine |
| Nomenclatura interna | "Framework" (ambíguo) | "Engine" (preciso) |
| Testes unitários | Impossível sem engine real | Mock `IConnectionStrategy` injetável |
| Arquivos `.inc` em `Source\Connection` | 11 arquivos | 0 |
| Arquivos `.inc` em `Source\Connector` | 2 arquivos | 0 |
| API pública (`TConnection`, `TQuery`, `TConnector`) | — | Preservada sem quebra |
| Engines suportadas | dbExpress, FireDAC, ZeOS | dbExpress, FireDAC, ZeOS, **UniDAC** + extensível |
| Drivers suportados | SQLite, MySQL, Firebird, Interbase, MSSQL, PostgreSQL, Oracle | Idem — extensível |
