# Connection.Engine

Implementações de **`IConnectionStrategy`**, **`IQueryStrategy`** e **`IEngineFactory`** por biblioteca (**dbExpress**, **FireDAC**, **ZeOS**, **UniDAC**), alinhadas ao enum `TEngine` em `Connection.Types`.

## Organização

```
Engine/
└── Adapters/
    ├── Connection.All.pas          ← todas as engines (usa os quatro * .All abaixo)
    ├── dbExpress/
    │   ├── Connection.dbExpress.All.pas
    │   ├── Core/                   ← Factory, ConnectionStrategy, QueryStrategy
    │   └── Drivers/                ← dbExpress.Driver.* (um por TDriver)
    ├── FireDAC/
    │   ├── Connection.FireDAC.All.pas
    │   ├── Core/
    │   └── Drivers/
    ├── ZeOS/
    │   ├── Connection.ZeOS.All.pas
    │   ├── Core/
    │   └── Drivers/
    └── UniDAC/
        ├── Connection.UniDAC.All.pas
        ├── Core/
        └── Drivers/
```

## Agregadores `Connection.*.All`

| Unit | Escopo | Quando usar |
|------|--------|-------------|
| `Connection.All` | dbExpress + FireDAC + ZeOS + UniDAC | Demo completo ou app que oferece todas as engines. |
| `Connection.dbExpress.All` | Só dbExpress | Projeto apenas dbExpress. |
| `Connection.FireDAC.All` | Só FireDAC | Ex.: `GenericDataTypes`. |
| `Connection.ZeOS.All` | Só ZeOS | Cliente ZeOSLib apenas. |
| `Connection.UniDAC.All` | Só UniDAC | Cliente Devart UniDAC (licença). |

Cada agregador só declara `interface uses` (sem tipos novos): força o *link* das units para que os blocos `initialization` dos `*.Factory.pas` executem e registrem a engine no `EngineRegistry`.

**Validação:** `Connection.All` deve listar os quatro `Connection.*.All` separados por vírgula (sintaxe Delphi). Cada `Connection.<engine>.All` deve incluir exatamente os três `.pas` de `Core` e os sete `Driver.*` existentes na pasta `Drivers/`.

## Registro no `EngineRegistry`

O registro continua em `initialization` em cada `Core\<engine>.Factory.pas` (padrão já documentado no README raiz).

## Search path (projetos sem pacote)

Para compilar um agregador, o compilador precisa achar `Core` e `Drivers` de **cada** engine puxada pela cadeia de `uses`. Exemplo mínimo para `Connection.All`:

- `...\Engine\Adapters\dbExpress\Core` e `...\Drivers`
- idem para `FireDAC`, `ZeOS`, `UniDAC`

O projeto **GenericConnector** já define esses caminhos em `DCC_UnitSearchPath`.

## Pacote Delphi

O arquivo [GenericDatabase.Connection.Engine.dpk](../../Packages/GenericDatabase.Connection.Engine.dpk) lista o mesmo conjunto de units. **UniDAC (Devart)** não tem nome de pacote fixo entre versões: se o link falhar, inclua no `requires` do `.dpk` os pacotes runtime da sua instalação (por exemplo variantes de `dac` / `unidac` com sufixo de versão). Detalhes em [Packages/README.md](../../Packages/README.md).

## Dependências por engine

| Engine | Observação |
|--------|------------|
| dbExpress | RTL + drivers DBX da instalação RAD Studio. |
| FireDAC | Pacotes FireDAC + drivers físicos (SQLite, IB, PG, MSSQL, MySQL, Oracle, …). |
| ZeOS | Pacotes **ZCore**, **ZComponent**, **ZParseSql**, **ZDbc**, **ZPlain** (ZeOSLib). |
| UniDAC | Units/pacotes comerciais Devart; ver comentários em `UniDAC.Factory.pas`. |
