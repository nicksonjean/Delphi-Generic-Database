# `Source\Connection`

Camada de conexão e execução de queries com **Strategy Pattern** e suporte a múltiplas engines (FireDAC, dbExpress, ZeOS, UniDAC).

## Núcleo

- **`Connection` / `Connection.Intf` / `Connection.Types`**: API pública (`TConnection`/interfaces) + tipos/constantes.
- **`EngineRegistry`**: registry de factories por engine.
- **`Query` / `QueryBuilder`**: execução e construção de SQL com helpers (`Type.*`).

## Engines

Ver `Engine\README.md`. O agregador `Connection.All` (em `Connection\Engine\Adapters\Connection.All.pas`) força o linkage das quatro engines (desde que as units `Connection.<Engine>.All` estejam no projeto/pacote ou no search path).

## Config (opcional)

Ver `Config\README.md` para loaders (INI/JSON/XML/YAML/TOML) e factory.

## Pacotes

Os `.dpk` ficam em `Source\Packages\` (ver `Source\Packages\README.md`).

