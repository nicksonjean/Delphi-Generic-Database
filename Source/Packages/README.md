# Pacotes Delphi (`*.dpk`)

| Arquivo | Conteúdo |
|---------|-----------|
| [GenericDatabase.Connection.Core.dpk](GenericDatabase.Connection.Core.dpk) | Núcleo partilhado: `Connection.Types`, `Connection.Strategy.Intf`, `Connection.Intf`, `EngineRegistry`, `Connection` — requerido por **Config**, cada **Engine.*** e o metapackage **Engine**. |
| [GenericDatabase.Connection.Config.dpk](GenericDatabase.Connection.Config.dpk) | Requer **Core** + **todo** o subtree `Connection.Config` (Static, Adapters, Factory, `Connection.Config.All`). |
| [GenericDatabase.Connection.Engine.dpk](GenericDatabase.Connection.Engine.dpk) | **Metapackage:** requer **Core** + os quatro pacotes por engine abaixo; contém só `Connection.All.pas`. Compile **Core** primeiro; depois cada engine; por fim este (ou use só um `Engine.*.dpk` para um único BPL de engine). |
| [GenericDatabase.Connection.Engine.DbExpress.dpk](GenericDatabase.Connection.Engine.DbExpress.dpk) | Base `Connection` + apenas dbExpress (Core `*.Connection.Strategy` / `*.Query.Strategy`, drivers, `Connection.dbExpress.All`) — útil para testar só esta engine. |
| [GenericDatabase.Connection.Engine.FireDAC.dpk](GenericDatabase.Connection.Engine.FireDAC.dpk) | Idem para FireDAC. |
| [GenericDatabase.Connection.Engine.ZeOS.dpk](GenericDatabase.Connection.Engine.ZeOS.dpk) | Idem para ZeOS. |
| [GenericDatabase.Connection.Engine.UniDAC.dpk](GenericDatabase.Connection.Engine.UniDAC.dpk) | Idem para UniDAC (**ajuste `requires`** aos BPLs Devart da sua instalação). |
| [GenericDatabase.Types.All.dpk](GenericDatabase.Types.All.dpk) | `Type.*` em `Source\Types` (String, DateTime, Array) + `MimeType` + agregador **`Type.All`**. |
| [GenericDatabase.EventDriven.All.dpk](GenericDatabase.EventDriven.All.dpk) | `EventDriven.*` em `Source\EventDriven` + agregador **`EventDriven.All`**. |

## Config

- **Requires:** `rtl`, `xmlrtl`, `dbrtl`.
- Para **YAML** / **TOML** nos loaders, mantenha no library path do IDE (ou no projeto) as pastas **Neslib.Yaml** e **DelphiTOML**, como no demo `GenericConnector`.

## Engine

- Cada pacote **Engine.DbExpress**, **Engine.FireDAC**, **Engine.ZeOS** e **Engine.UniDAC** declara apenas os `requires` dessa stack. O pacote agregador **Connection.Engine** junta os quatro via `requires` e publica `Connection.All`.
- Os nomes dos pacotes FireDAC **UniDAC** podem variar entre versões do RAD Studio; ajuste conforme o erro de link do `dcc`.
- **UniDAC:** em `GenericDatabase.Connection.Engine.UniDAC.dpk`, substitua ou complemente `rtl, dbrtl` pelos pacotes runtime Devart (`dac`, `unidac`, etc.) da sua instalação.
- Primeira compilação: abra o `.dpk` no IDE e **Build**; o ficheiro `.res` é gerado se necessário. Para só uma engine: compile apenas o `.dpk` correspondente (não precisa do metapackage).

## Uso

1. **Project → Options → Packages → Runtime packages** — adicionar o `.bpl` gerado, **ou**
2. Compilar a aplicação com **units no path** (como os demos), sem instalar o BPL.
