# Demo projects: fixing `F2613 Unit … not found` (Delphi search path)

This note covers common FireMonkey demo build issues: missing **Connection engine** folders and missing **Neslib.Yaml** / **DelphiTOML** (`unit TOML`). Fix by extending `DCC_UnitSearchPath` in the demo `.dproj` (not the `.dpr`), using `Source\Vendor` and/or `Demo\modules` (Boss).

---

## 1. Connection engines (`Connection.dbExpress.All`, `ZeOS`, `UniDAC`)

### Symptom

When building a FireMonkey demo (for example `Demo/GenericDataTypes.dproj`), the compiler stops with errors such as:

- `F2613 Unit 'Connection.dbExpress.All' not found`
- unresolved `Connection.ZeOS.All`, `Connection.UniDAC.All`

The IDE underlines those units in `Source/Connection/Engine/Adapters/Connection.Engine.All.pas`.

`Connection.FireDAC.All` may still resolve, while the others fail.

### Why the `.dpr` can look “the same” but only one project breaks

`GenericConnector.dpr` and `GenericDataTypes.dpr` can list the same units in the program `uses` clause; that does **not** control where the compiler looks for **transitive** dependencies.

`Connection.All` (and the connector stack) pulls in `Connection.Engine.All`, which intentionally references all four engine aggregates:

```pascal
uses
  Connection.dbExpress.All,
  Connection.FireDAC.All,
  Connection.ZeOS.All,
  Connection.UniDAC.All;
```

The compiler must find the `.pas` (or `.dcu`) for each of those units. That is driven by the **Unit search path** (`DCC_UnitSearchPath`) in the **`.dproj`**, not by the `.dpr` alone.

Those units live under separate folders:

| Unit aggregate        | Typical source roots (relative to repo) |
|-----------------------|----------------------------------------|
| `Connection.dbExpress.*` | `Source/Connection/Engine/Adapters/dbExpress` (+ `Core`, `Drivers`) |
| `Connection.FireDAC.*`   | `Source/Connection/Engine/Adapters/FireDAC` (+ `Core`, `Drivers`) |
| `Connection.UniDAC.*`    | `Source/Connection/Engine/Adapters/UniDAC` (+ `Core`, `Drivers`) |
| `Connection.ZeOS.*`      | `Source/Connection/Engine/Adapters/ZeOS` (+ `Core`, `Drivers`) |

If the project only adds the FireDAC branches of that tree, FireDAC resolves and the other three do not.

A project that already built on your machine (e.g. `GenericConnector`) might have appeared “fixed” if search paths were adjusted in the IDE and stored locally, or if you compared an older `.dproj` state. **Authoritative** configuration for sharing and CI is the committed `.dproj`.

### Fix (applied in this repo)

Extend `DCC_UnitSearchPath` in the demo `.dproj` so it includes **all** engine adapter folders, in line with `Demo/GenericQueryBuilder.dproj`.

Concretely, after `..\Source\Connection\Engine\Adapters`, add:

- `..\Source\Connection\Engine\Adapters\dbExpress`, `dbExpress\Core`, `dbExpress\Drivers`
- (keep existing FireDAC entries)
- `..\Source\Connection\Engine\Adapters\UniDAC`, `UniDAC\Core`, `UniDAC\Drivers`
- `..\Source\Connection\Engine\Adapters\ZeOS`, `ZeOS\Core`, `ZeOS\Drivers`

#### Projects updated (engine paths)

- `Demo/GenericDataTypes.dproj`, `Demo/GenericConnector.dproj` — extended engine adapter paths so `Connection.Engine.All` resolves all four backends.

---

## 2. Neslib.Yaml / DelphiTOML (`Neslib.Yaml`, `TOML` not found)

### Symptom

- `F2613 Unit 'TOML' not found` (often first reported from `Source/Connection/Config/Connection.Config.DocumentRefs.pas`, which uses `TOML` and is pulled in by the Connection.Config stack).
- Similar errors for `Neslib.Yaml` when YAML config code is compiled.
- `F2613 Unit 'Neslib.Utf8' not found` while compiling `Neslib.Yaml.pas` — see **Neslib submodule** below.

### Cause

[Neslib.Yaml](https://github.com/neslib/Neslib.Yaml) and [DelphiTOML](https://github.com/SilenceCCF/DelphiTOML) are **third-party** libraries. The Delphi compiler only sees them if their **folders** are on `DCC_UnitSearchPath`. The root `modules` entry is **not** enough: it does not search all subfolders, and `TOML.pas` lives under **`DelphiTOML\src`**, not under `DelphiTOML\` alone.

You can supply these libraries in either way:

| Layout | Purpose |
|--------|---------|
| **`Demo/modules/...`** | After `boss install` in `Demo/` (see `Demo/boss.json`). The `modules/` tree is gitignored. |
| **`Source/Vendor/...`** | Vendored clones (no Boss required). Recommended if Boss is not set up yet. |

Expected vendored layout (paths are relative to the repo root):

- `Source/Vendor/Neslib.Yaml/` — root of [Neslib.Yaml](https://github.com/neslib/Neslib.Yaml) (`Neslib.Yaml.pas`, `Neslib.LibYaml.pas`, …).
- **`Source/Vendor/Neslib.Yaml/Neslib/`** — **required**: this is the [Neslib](https://github.com/neslib/Neslib) **git submodule** (see `.gitmodules` in Neslib.Yaml). It contains `Neslib.Utf8.pas` and related units. If you cloned Neslib.Yaml as a **zip** or without submodules, this folder is empty: run `git submodule update --init --recursive` inside `Neslib.Yaml`, **or** clone [neslib/Neslib](https://github.com/neslib/Neslib) separately into `Source/Vendor/Neslib` (same files as the submodule).
- `Source/Vendor/DelphiTOML/src/` — must contain `TOML.pas`, `TOML.Types.pas`, etc.
- Optionally `Tests\…` under Neslib.Yaml if you need those units.

### Fix (applied in this repo)

`DCC_UnitSearchPath` in the demo `.dproj` files includes **both**:

1. **`..\Source\Vendor\...`** first — picks up your copies under `Source\Vendor`.
2. **`modules\...`** after that — still works when Boss populates `Demo\modules`.

Concrete entries:

- `..\Source\Vendor\Neslib.Yaml`
- `..\Source\Vendor\Neslib.Yaml\Neslib` (submodule → `Neslib.Utf8`)
- `..\Source\Vendor\Neslib` (fallback if you cloned the Neslib repo on its own)
- `..\Source\Vendor\Neslib.Yaml\Tests\UnitTests\Tests`
- `..\Source\Vendor\Neslib.Yaml\Tests\YamlDump`
- `..\Source\Vendor\DelphiTOML\src`
- (then the same Neslib / DelphiTOML patterns under `modules\` for Boss users, including `modules\Neslib.Yaml\Neslib` and `modules\Neslib`)

This matches the hint in `Source/Packages/GenericDatabase.Connection.Config.All.dpk`: library path should include `DelphiTOML\src` and Neslib.Yaml.

#### Projects updated (YAML + TOML search paths)

- `Demo/GenericDataTypes.dproj`
- `Demo/GenericConnector.dproj`
- `Demo/GenericQueryBuilder.dproj`
- `Demo/GenericPagNav.dproj`

---

## Optional: set the same paths in the IDE

**Project → Options → Delphi Compiler → Unit search path** — ensure the same folders are present (or rely on the updated `.dproj` after reload).

## Reference

- Full **engine** adapter path set: `Demo/GenericQueryBuilder.dproj` (`DCC_UnitSearchPath` in the base `PropertyGroup`).
- **Optional Boss dependencies:** `Demo/boss.json` (`Neslib.Yaml`, `DelphiTOML`, etc.) — use when `boss install` works; otherwise rely on `Source/Vendor` as above.
