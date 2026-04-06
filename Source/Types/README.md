# `Source\Types`

Biblioteca de tipos auxiliares (strings, datas, matrizes associativas) usada por `QueryBuilder`, `Connector` e pelos demos.

## Pastas

| Pasta | Units (prefixo `Type.`) |
|-------|-------------------------|
| [String](String/) | `Type.String` |
| [Float](Float/) | `Type.Locale`, `Type.Float` (+ `Type.Money.json` / `Type.Money.json.inc` incluidos por `Type.Float`) |
| [DateTime](DateTime/) | `Type.DateTime` |
| [Array](Array/) | `Type.Array.Guard.Intf`, `Type.Array.Intf`, `Type.Array`, `Type.Array.String`, `Type.Array.String.Helper`, `Type.Array.Variant`, `Type.Array.Variant.Helper`, `Type.Array.Field`, `Type.Array.Field.Helper`, `Type.Array.Assoc` |

## Agregador

- **`Type.All`** ([Type.All.pas](Type.All.pas)) — um `uses Type.All` puxa todas as units acima e **`MimeType`** (`Source\Reflection`), necessario para varias matrizes.

## Pacote Delphi

- **`Source\Packages\GenericDatabase.Types.All.dpk`** — BPL com as mesmas units + `Type.All`. Requer `rtl`, `dbrtl`, `fmx` (FireMonkey e `Data.DB` / `REST.JSON` nas dependencias).

## Projetos sem BPL

Os demos listam cada `.pas` com caminho `String\`, `DateTime\` ou `Array\` no `dpr` / `dproj`, ou podem depender do pacote compilado.

## Dicas de uso

- **Strings/Locale**: `Type.String` + `Type.Locale`.
- **Monetário/Decimal**: `Type.Float` inclui (via `{$I Type.Money.json.inc}`) a tabela `Type.Money.json` (fica em `Float\`).
- **Matrizes associativas**: `Type.Array.*` (String/Variant/Field/Assoc) + `Type.Array.*.Helper`.
