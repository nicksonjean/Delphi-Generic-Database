# `Source\EventDriven`

Biblioteca **EventDriven** para delegação de eventos com *method references* (closures) no FireMonkey, encapsulando a criação de handlers (wrappers) baseados em `TComponent`.

## Estrutura

| Pasta | Conteúdo |
|------|----------|
| `Core\` | `EventDriven.Core`, `EventDriven.Types`, `EventDriven` (fachada) |
| `Delegates\` | Wrappers `Delegate*` para `Notify`, `Key`, `Paint`, `ItemBox`, `ItemView`, `ItemButton`, `ItemUpdating` |
| `Bindings\` | `EventDriven.GridBindings` (delegates para `FMX.Grid`) |

## Agregador

- **`EventDriven.All`** (`EventDriven.All.pas`): um único `uses EventDriven.All` puxa todas as units públicas.

## Pacote Delphi

- **`Source\Packages\GenericDatabase.EventDriven.All.dpk`**: pacote runtime com todas as units acima + `EventDriven.All`.

