# Delphi-Generic-Database

![Delphi Supported Versions](https://img.shields.io/badge/Delphi-XE10%20Seattle%20..%20XE12%20Athens-blue.svg)
![Platforms](https://img.shields.io/badge/Platforms-Win32%20%7C%20Win64%20%7C%20Android%20%7C%20iOS-red.svg)
![License](https://img.shields.io/badge/License-LGPL--3.0-green.svg)

**Delphi-Generic-Database** é uma biblioteca Delphi para conexão genérica a bancos de dados e exibição dos dados em componentes nativos FMX de forma rápida, simples e desacoplada. Toda a lógica de engine é isolada via **Strategy Pattern**.

---

## Bancos de Dados Suportados

| Engine | SQLite | MySQL/MariaDB | Firebird | Interbase | PostgreSQL | SQL Server | Oracle |
|--------|:------:|:-------------:|:--------:|:---------:|:----------:|:----------:|:------:|
| FireDAC | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| dbExpress | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| ZeOSLib | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| UniDAC | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |

---

## Arquitetura

```
Source/
├── Connection/                  # Camada de acesso a dados
│   ├── Connection.pas           # IConnection + TConnection (Strategy Pattern)
│   ├── Connection.Types.pas     # TDriver, TEngine, TConnectionParams
│   ├── Query.pas                # TQuery — execução de consultas
│   ├── QueryBuilder.pas         # TQueryBuilder — construção SQL genérica
│   ├── Helpers/QueryHelper.pas  # Helper de extensão para TQuery
│   ├── Registry/                # EngineRegistry — auto-registro via Factory.initialization
│   ├── Strategy/                # Interfaces: IConnectionStrategy, IQueryStrategy, IEngineFactory, IDriverConfigurator
│   ├── Adapters/                # Implementações concretas por engine
│   │   ├── FireDAC/             #   ConnectionStrategy, QueryStrategy, Factory, Drivers (7 BDs)
│   │   ├── dbExpress/           #   idem
│   │   ├── ZeOS/                #   idem
│   │   └── UniDAC/              #   idem
│   └── Config/                  # Carregamento de configuração
│       ├── Connection.Config.INI.pas
│       ├── Connection.Config.JSON.pas
│       └── Connection.Config.XML.pas
├── Connector/                   # Binding de TQuery a componentes FMX
│   ├── Connector.pas            # TConnector — métodos ToGrid, ToStringGrid, ToListBox, ToListView, ToComboBox, ToComboEdit, ToEdit
│   ├── OptionsArray.pas
│   ├── OptionsInteger.pas
│   └── OptionsJSON.pas
├── Types/                       # Tipos auxiliares
│   ├── Array/                   # Arrays associativos PHP-like
│   │   ├── ArrayString.pas      #   Bidimensional de strings (herda TStringList)
│   │   ├── ArrayVariant.pas     #   Genérico TDictionary<Variant, Variant>
│   │   ├── ArrayField.pas       #   TDictionary<Variant, TField>
│   │   ├── ArrayAssoc.pas       #   Multidimensional aninhado
│   │   └── Helpers/             #   ArrayStringHelper, ArrayVariantHelper, ArrayFieldHelper
│   ├── Date.pas / Time.pas / TimeDate.pas
│   ├── Float.pas / Strings.pas
│   ├── Locale/Locale.pas        # Localização e formatação regional
│   └── Money.Types.json         # Definições de tipos monetários
├── Helpers/                     # Class helpers para componentes FMX
│   ├── FMX.Edit/                # TEdit helper
│   ├── FMX.ComboBox/            # TComboBox helper
│   ├── FMX.ComboEdit/           # TComboEdit helper
│   ├── FMX.Grid/                # TGrid helper
│   ├── FMX.StringGrid/          # TStringGrid helper
│   ├── FMX.ListBox/             # TListBox helper
│   ├── FMX.ListView/            # TListView helper
│   ├── FMX.Objects/             # Objetos FMX helpers
│   ├── ArrayHelper/             # Helper genérico de array
│   └── DictionaryHelper/        # Helper genérico de dicionário
├── Extensions/                  # Extensões de componentes FMX
│   ├── FMX.Edit/                # FMX.Edit.Extension — funcionalidades extras para TEdit
│   └── FMX.ListView/            # FMX.ListView.Extension — suporte multi-versão (Berlin..Sydney)
├── SmartPointer/                # Gerenciamento automático de ciclo de vida
│   ├── ISmartPointer.pas
│   └── TSmartPointer.pas        # TSmartPointer<T> — RAII genérico compatível com TInterfacedObject
├── EventDriven/
│   └── EventDriven.pas          # Delegação de eventos no padrão MVE (Model-View-Event)
├── Reflection/
│   ├── RTTI.pas                 # Utilitários de reflexão RTTI
│   ├── Registry.pas             # Registry genérico
│   └── MimeType.pas             # Detecção de MIME types por extensão/stream
└── Vendor/                      # Dependências embutidas
    ├── FastMM4/                 # Memory manager FastMM4
    ├── FastMM5/                 # Memory manager FastMM5
    └── XSuperObject/            # Parser JSON de alta performance
```

---

## Componentes Principais

### Connection — Conexão Genérica a Bancos de Dados

`TConnection` implementa `IConnection` e delega toda a lógica de engine para `IConnectionStrategy`. Para ativar uma engine, basta incluir a unit de seu `Factory.pas` no projeto — o registro ocorre automaticamente via `initialization`.

**Conexão direta (gerenciamento manual):**

```delphi
uses
  Connection, Connection.Types,
  FireDAC.Factory; // registra FireDAC no EngineRegistry

var
  DB: TConnection;
begin
  DB := TConnection.Create(TEngine.FireDAC);
  try
    DB.Driver   := TDriver.MySQL;
    DB.Host     := 'localhost';
    DB.Port     := 3306;
    DB.Database := 'mydb';
    DB.Username := 'root';
    DB.Password := 'secret';
    DB.Connected := True;
    // ... uso
  finally
    DB.Destroy;
  end;
end;
```

**Conexão com SmartPointer — FireDAC/SQLite:**

`TSmartPointer<T>` elimina o `try/finally` manual: a conexão e a query são liberadas automaticamente ao sair do escopo. O `TConnector` é obtido via cast implícito de `ISmartPointer<TConnector>`, também sem `Free` explícito.

```delphi
uses
  Connection, Connection.Types, Query, QueryBuilder, Connector,
  ISmartPointer, TSmartPointer,
  FireDAC.Factory;

var
  DB:        TSmartPointer<TConnection>;
  SQL:       TSmartPointer<TQuery>;
  QBuilder:  TQueryBuilder;
  Connector: TConnector;
begin
  // SmartPointer gerencia TConnection — sem try/finally
  DB := TSmartPointer<TConnection>.Create(TConnection.Create(TEngine.FireDAC));
  DB.Ref.Driver   := TDriver.SQLite;
  DB.Ref.Database := ExtractFilePath(ParamStr(0)) + 'DB.SQLITE';

  if not DB.Ref.Connected then
    DB.Ref.Connected := True;

  QBuilder := TQueryBuilder.ForConnection(DB.Ref.GetConnectionStrategy);

  // SmartPointer gerencia TQuery
  SQL := TSmartPointer<TQuery>.Create(QBuilder.View('SELECT id AS Codigo, nome AS Estado, sigla AS Sigla FROM estado ORDER BY id'));

  // TConnector via ISmartPointer — liberado com o escopo
  Connector := ISmartPointer<TConnector>(TConnector.Create(SQL.Ref));

  Connector.ToCombo(ComboBoxSQLite,  'Codigo', 'Estado', '{"Index":1}');
  Connector.ToCombo(EditSQLite,      'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
  Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', '{"Index":5}');
  Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', '{"Field":{"Estado":"Bahia"}}');
  Connector.ToGrid(StringGridSQLite, '{"Field":{"Sigla":"AP"}}');
  Connector.ToGrid(GridSQLite,       '{"Field":{"Estado":"Distrito Federal"}}');
  Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');
end;
```

**Conexão com SmartPointer — dbExpress/SQLite:**

Idêntico ao anterior mas usando `dbExpress.Factory`. O `TConnector` é gerenciado com `try/finally` explícito enquanto `TConnection` e `TQuery` ficam sob `TSmartPointer`.

```delphi
uses
  Connection, Connection.Types, Query, QueryBuilder, Connector,
  TSmartPointer,
  dbExpress.Factory;

var
  DB:        TSmartPointer<TConnection>;
  SQL:       TSmartPointer<TQuery>;
  QBuilder:  TQueryBuilder;
  Connector: TConnector;
begin
  DB := TSmartPointer<TConnection>.Create(TConnection.Create(TEngine.dbExpress));
  DB.Ref.Driver   := TDriver.SQLite;
  DB.Ref.Database := ExtractFilePath(ParamStr(0)) + 'DB.SQLITE';

  if not DB.Ref.Connected then
    DB.Ref.Connected := True;

  QBuilder := TQueryBuilder.ForConnection(DB.Ref.GetConnectionStrategy);
  SQL := TSmartPointer<TQuery>.Create(QBuilder.View('SELECT id AS Codigo, nome AS Estado, sigla AS Sigla FROM estado ORDER BY id'));

  Connector := TConnector.Create(SQL.Ref);
  try
    Connector.ToCombo(ComboBoxSQLite,  'Codigo', 'Estado', '{"Index":1}');
    Connector.ToCombo(EditSQLite,      'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
    Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', '{"Index":5}');
    Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', '{"Field":{"Estado":"Bahia"}}');
    Connector.ToGrid(StringGridSQLite, '{"Field":{"Sigla":"AP"}}');
    Connector.ToGrid(GridSQLite,       '{"Field":{"Estado":"Distrito Federal"}}');
    Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');
  finally
    Connector.Free;
  end;
end;
```

**Configuração a partir de arquivo:**

```delphi
uses Connection.Config.INI;

var Conn: IConnection;
begin
  Conn := TConnectionConfigINI.FromFile('config.ini');
  Conn.Connect := True;
end;
```

Formatos suportados: **INI**, **JSON**, **XML**.

---

### Query — Execução de Consultas

`TQuery` encapsula a execução de SQL sobre uma `IConnection` de forma agnóstica à engine.

```delphi
uses Query;

var Q: TQuery;
begin
  Q := TQuery.Create(Conn);
  Q.SQL := 'SELECT * FROM users WHERE active = :active';
  Q.Params['active'] := True;
  Q.Open;
  while not Q.EOF do
  begin
    Writeln(Q.Fields['name'].AsString);
    Q.Next;
  end;
end;
```

---

### QueryBuilder — Construção SQL Genérica

`TQueryBuilder` é um record que oferece métodos genéricos para montar e executar `SELECT`, `INSERT`, `UPDATE`, `DELETE` e `REPLACE` usando os tipos `Array*` como entrada de colunas e filtros.

```delphi
uses QueryBuilder, ArrayVariant;

var
  QB:   TQueryBuilder;
  Data: TArrayVariant;
begin
  QB.Use(Conn.GetConnectionStrategy);

  Data := TArrayVariant.Create;
  Data['name']  := 'John';
  Data['email'] := 'john@example.com';

  QB.Insert('users', Data, {Run=}True);
end;
```

---

### Connector — Binding de TQuery a Componentes FMX

`TConnector` substitui os componentes `DB*` do VCL (DBGrid, DBEdit, etc.) para FMX, conectando uma `TQuery` diretamente aos componentes nativos do FireMonkey, inclusive de forma bidirecional.

| Método | Componente | Parâmetros-chave |
|--------|-----------|-----------------|
| `ToGrid` | TGrid / TStringGrid | filtro JSON opcional |
| `ToListBox` | TListBox | campo-chave, campo-label, filtro JSON |
| `ToListView` | TListView | campo-chave, campo-label, campos extras, filtro JSON |
| `ToCombo` | TComboBox / TComboEdit / TEdit | campo-chave, campo-label, filtro JSON |

O parâmetro de filtro aceita JSON com duas estratégias:

| Estratégia | JSON | Significado |
|------------|------|-------------|
| Por índice | `{"Index": 5}` | Seleciona a linha pelo índice (base 0) |
| Por campo  | `{"Field": {"nome_campo": "valor"}}` | Seleciona a primeira linha cujo campo bata com o valor |

**Exemplo completo — Firebird via FireDAC:**

```delphi
uses
  Connection, Connection.Types, Query, QueryBuilder, Connector,
  FireDAC.Factory;

var
  DB:       TConnection;
  SQL:      TQuery;
  QBuilder: TQueryBuilder;
  Conn:     TConnector;
begin
  DB := TConnection.Create(TEngine.FireDAC);
  try
    DB.Driver   := TDriver.Firebird;
    DB.Host     := 'localhost';
    DB.Port     := 3050;
    DB.Database := '/firebird/data/DB.FDB';
    DB.Username := 'sysdba';
    DB.Password := 'masterkey';
    DB.Connected := True;

    QBuilder := TQueryBuilder.ForConnection(DB.GetConnectionStrategy);
    SQL := nil;
    try
      SQL := QBuilder.View(
        'SELECT "id" AS "Codigo", "nome" AS "Estado", "sigla" AS "Sigla" ' +
        'FROM "estado" ORDER BY "id"');

      Conn := TConnector.Create(SQL);
      try
        // TComboBox — seleciona pelo índice
        Conn.ToCombo(ComboBoxFirebird, 'Codigo', 'Estado', '{"Index":1}');
        // TEdit — seleciona pelo valor do campo Codigo = 3
        Conn.ToCombo(EditFirebird,     'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        // TComboEdit — seleciona pelo índice 5
        Conn.ToCombo(ComboEditFirebird,'Codigo', 'Estado', '{"Index":5}');
        // TListBox — filtra por nome de estado
        Conn.ToListBox(ListBoxFirebird,'Codigo', 'Estado', '{"Field":{"Estado":"Bahia"}}');
        // TStringGrid — filtra por sigla
        Conn.ToGrid(StringGridFirebird,'{"Field":{"Sigla":"AP"}}');
        // TGrid — filtra por nome completo
        Conn.ToGrid(GridFirebird,      '{"Field":{"Estado":"Distrito Federal"}}');
        // TListView — múltiplos campos visíveis, filtra por sigla
        Conn.ToListView(ListViewFirebird, 'Codigo', 'Estado',
          ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');
      finally
        Conn.Destroy;
      end;
    finally
      SQL.Free;
    end;
  finally
    DB.Destroy;
  end;
end;
```

**Exemplo — MySQL/MariaDB via FireDAC:**

```delphi
DB := TConnection.Create(TEngine.FireDAC);
DB.Driver := TDriver.MySQL;  DB.Host := 'localhost';  DB.Port := 3306;
DB.Database := 'demodev';    DB.Username := 'root';   DB.Password := 'masterkey';
DB.Connected := True;

QBuilder := TQueryBuilder.ForConnection(DB.GetConnectionStrategy);
SQL := QBuilder.View('SELECT id AS Codigo, nome AS Estado, sigla AS Sigla FROM estado ORDER BY id');

Conn := TConnector.Create(SQL);
Conn.ToCombo(ComboBoxMySQL,  'Codigo', 'Estado', '{"Index":1}');
Conn.ToListBox(ListBoxMySQL, 'Codigo', 'Estado', '{"Field":{"Estado":"Bahia"}}');
Conn.ToGrid(GridMySQL,       '{"Field":{"Estado":"Distrito Federal"}}');
Conn.ToListView(ListViewMySQL, 'Codigo', 'Estado',
  ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');
```

**Exemplo — PostgreSQL via FireDAC:**

```delphi
DB := TConnection.Create(TEngine.FireDAC);
DB.Driver := TDriver.PostgreSQL;  DB.Host := 'localhost';  DB.Port := 5432;
DB.Schema := 'public';  DB.Database := 'demodev';
DB.Username := 'postgres';  DB.Password := 'masterkey';
DB.Connected := True;

SQL := TQueryBuilder.ForConnection(DB.GetConnectionStrategy).View(
  'SELECT "id" AS "Codigo", "nome" AS "Estado", "sigla" AS "Sigla" FROM "estado" ORDER BY "id"');

Conn := TConnector.Create(SQL);
Conn.ToGrid(StringGridPostgreSQL, '{"Field":{"Sigla":"AP"}}');
Conn.ToGrid(GridPostgreSQL,       '{"Field":{"Estado":"Distrito Federal"}}');
```

**Exemplo — SQL Server via FireDAC:**

```delphi
DB := TConnection.Create(TEngine.FireDAC);
DB.Driver := TDriver.MSSQL;  DB.Host := 'localhost';  DB.Port := 1433;
DB.Database := 'demodev';    DB.Username := 'sa';     DB.Password := 'masterkey';
DB.Connected := True;

SQL := TQueryBuilder.ForConnection(DB.GetConnectionStrategy).View(
  'SELECT "id" AS "Codigo", "nome" AS "Estado", "sigla" AS "Sigla" FROM "estado" ORDER BY "id"');

Conn := TConnector.Create(SQL);
Conn.ToListView(ListViewMSSQL, 'Codigo', 'Estado',
  ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');
```

**Exemplo — Oracle via FireDAC:**

```delphi
DB := TConnection.Create(TEngine.FireDAC);
DB.Driver := TDriver.Oracle;  DB.Host := 'localhost';  DB.Port := 1521;
DB.Schema := 'HR';  DB.Database := 'ORCL';
DB.Username := 'hr';  DB.Password := 'masterkey';
DB.Connected := True;

SQL := TQueryBuilder.ForConnection(DB.GetConnectionStrategy).View(
  'SELECT "id" AS "Codigo", "nome" AS "Estado", "sigla" AS "Sigla" FROM HR."estado" ORDER BY "id"');

Conn := TConnector.Create(SQL);
Conn.ToGrid(GridOracle, '{"Field":{"Estado":"Distrito Federal"}}');
Conn.ToListView(ListViewOracle, 'Codigo', 'Estado',
  ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');
```

---

### Tipos Array — Arrays Associativos PHP-Like

Quatro variantes de arrays associativos para uso como parâmetros do `QueryBuilder` e estruturas internas:

| Classe | Herança | Uso |
|--------|---------|-----|
| `TArrayString` | `TStringList` | Array bidimensional exclusivamente de strings |
| `TArrayVariant` | `TDictionary<Variant, Variant>` | Array genérico com chaves e valores `Variant` |
| `TArrayField` | `TDictionary<Variant, TField>` | Mapeamento de campo para `TField` |
| `TArrayAssoc` | `TDictionary<Variant, TPair<Variant, TArrayAssoc>>` | Array multidimensional aninhado |

---

### SmartPointer — Gerenciamento de Ciclo de Vida

`TSmartPointer<T>` é um record RAII que libera automaticamente objetos ao sair de escopo. Compatível com `TInterfacedObject` (usa `_Release` em vez de `Free` quando aplicável).

```delphi
uses TSmartPointer;

var SP: TSmartPointer<TMyClass>;
begin
  SP := TMyClass.Create;
  SP.Ref.DoSomething; // liberado automaticamente ao fim do escopo
end;
```

---

### EventDriven — Delegação de Eventos (MVE)

`EventDriven.pas` provê infraestrutura para delegação de eventos no padrão **MVE (Model-View-Event)**, separando a lógica de UI da lógica de negócio em aplicações FMX.

---

### Bibliotecas de Configuração e Serialização (Vendor)

Além das dependências de acesso a dados, o projeto inclui (via Boss) as seguintes bibliotecas utilitárias:

| Biblioteca | Repositório | Finalidade |
|-----------|-------------|-----------|
| **FastMM4** | `github.com/pleriche/FastMM4` | Memory manager clássico para Delphi Win32 |
| **FastMM5** | `github.com/pleriche/FastMM5` | Memory manager moderno, multi-plataforma |
| **XSuperObject** | `github.com/onryldz/x-superobject` | Parser e serializador JSON de alta performance |
| **ZeOSLib** | `github.com/zeoslib/zeoslib` | Adapter de acesso a banco de dados (engine ZeOS) |
| **Neslib.Yaml** | `github.com/neslib/Neslib.Yaml` | Parser e emitter YAML via LibYAML — Win32/64, Android, iOS |
| **delphi-neon** | `github.com/paolo-rossi/delphi-neon` | Serialização/deserialização JSON com atributos RTTI |
| **DelphiTOML** | `github.com/SilenceCCF/DelphiTOML` | Parser TOML v1.1 completo para Delphi |

**Exemplo de leitura de configuração YAML (Neslib.Yaml):**

```delphi
uses Neslib.Yaml;

var
  Doc: IYamlDocument;
  Root: TYamlNode;
begin
  Doc := TYamlDocument.Load('config.yaml');
  Root := Doc.Root;
  Writeln(Root['database']['host'].ToString);
end;
```

**Exemplo de serialização com Neon:**

```delphi
uses Neon.Core.Persistence.JSON;

type
  TConfig = class
  public
    Host: String;
    Port: Integer;
  end;

var
  Cfg: TConfig;
  JSON: TJSONObject;
begin
  Cfg := TConfig.Create;
  Cfg.Host := 'localhost';
  Cfg.Port := 3306;
  JSON := TNeon.ObjectToJSON(Cfg) as TJSONObject;
  Writeln(JSON.ToJSON);
end;
```

**Exemplo de leitura TOML (DelphiTOML):**

```delphi
uses TOML;

var
  Doc: TTOMLDocument;
begin
  Doc := TTOMLParser.ParseFile('config.toml');
  try
    Writeln(Doc['database']['host'].AsString);
    Writeln(Doc['database']['port'].AsInteger.ToString);
  finally
    Doc.Free;
  end;
end;
```

---

## Instalação via Boss

```bash
boss install github.com/nicksonjean/Delphi-Generic-Database
```

## Instalação Manual

```bash
git clone https://github.com/nicksonjean/Delphi-Generic-Database.git
```

Adicione as seguintes pastas ao search path do projeto em **Project > Options > Resource Compiler > Directories and Conditionals > Include file search path**:

```
../Delphi-Generic-Database/Source/Connection
../Delphi-Generic-Database/Source/Connection/Adapters/FireDAC
../Delphi-Generic-Database/Source/Connection/Config
../Delphi-Generic-Database/Source/Connection/Registry
../Delphi-Generic-Database/Source/Connection/Strategy
../Delphi-Generic-Database/Source/Connector
../Delphi-Generic-Database/Source/EventDriven
../Delphi-Generic-Database/Source/Extensions/FMX.Edit
../Delphi-Generic-Database/Source/Extensions/FMX.ListView
../Delphi-Generic-Database/Source/Helpers/ArrayHelper
../Delphi-Generic-Database/Source/Helpers/DictionaryHelper
../Delphi-Generic-Database/Source/Helpers/FMX.ComboBox
../Delphi-Generic-Database/Source/Helpers/FMX.ComboEdit
../Delphi-Generic-Database/Source/Helpers/FMX.Edit
../Delphi-Generic-Database/Source/Helpers/FMX.Grid
../Delphi-Generic-Database/Source/Helpers/FMX.ListBox
../Delphi-Generic-Database/Source/Helpers/FMX.ListView
../Delphi-Generic-Database/Source/Helpers/FMX.Objects
../Delphi-Generic-Database/Source/Helpers/FMX.StringGrid
../Delphi-Generic-Database/Source/Reflection
../Delphi-Generic-Database/Source/SmartPointer
../Delphi-Generic-Database/Source/Types
../Delphi-Generic-Database/Source/Types/Array
../Delphi-Generic-Database/Source/Types/Locale
../Delphi-Generic-Database/Source/Vendor/FastMM5
../Delphi-Generic-Database/Source/Vendor/XSuperObject
```

> Substitua `FireDAC` pelo adapter desejado (`dbExpress`, `ZeOS` ou `UniDAC`) conforme sua engine.

---

## ToDo

- [x] Suporte completo a todos os bancos de dados (SQLite, Firebird/Interbase, MySQL/MariaDB, PostgreSQL, SQLServer, Oracle)
- [x] Adapters: FireDAC, dbExpress, ZeOS, UniDAC
- [x] Strategy Pattern — zero `$IFDEF` de engine no código principal
- [x] EngineRegistry com auto-registro via `initialization`
- [x] Configuração via INI, JSON e XML
- [x] QueryBuilder genérico (SELECT, INSERT, UPDATE, DELETE, REPLACE)
- [x] SmartPointer genérico com suporte a `TInterfacedObject`
- [x] Refatoração removendo arquivos `*.inc` de Connection, Connector e Types/Array
- [ ] Refatorar Types/TimeDate.pas
- [ ] Suporte a TeeGrid no Connector
- [ ] DBNavigator para TGrid e TStringGrid
- [ ] Paginação / "Carregar Mais" para ListBox e ListView
- [ ] Testes unitários

## Bugs Conhecidos

- [ ] Warnings do dbExpress para `StartTransaction`, `Commit` e `Rollback` (símbolos deprecated)
- [ ] Testes unitários para validar comportamento cross-engine

---

⁰¹²³⁴⁵⁶⁷⁸⁹
