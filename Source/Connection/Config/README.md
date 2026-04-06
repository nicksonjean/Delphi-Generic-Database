# Connection.Config

Carrega um `TConnection` configurado (sem abrir sessão) a partir de **INI**, **JSON**, **XML**, **YAML** ou **TOML**.

Inclua **`Connection.Config.All`** no `uses` do projeto para puxar Types, Core, Mapper, **Static** (loaders), Adapters e Factory.

Pacotes opcionais: [GenericDatabase.Connection.Config.dpk](../Packages/GenericDatabase.Connection.Config.dpk) e, para as engines, [GenericDatabase.Connection.Engine.dpk](../Packages/GenericDatabase.Connection.Engine.dpk) — ver [Packages/README.md](../Packages/README.md).

## Layout

| Caminho | Conteúdo |
|---------|----------|
| `Connection.Config.All.pas` | Agregador de units públicas |
| `Connection.Config.Types.pas` | `TConnectionConfigFormat`, `TConnectionConfigSourceKind`, extensões |
| `Connection.Config.DocumentRefs.pas` | Wrappers `TConnection*DocumentRef` para `LoadFromObject` |
| `Connection.Config.Intf.pas` | `IConnectionConfig` |
| `Connection.Config.Factory.pas` | `TConnectionConfigFactory` |
| `Core/Connection.Config.Loader.Abstract.pas` | `TConnectionConfigLoader` (abstrato) |
| `Mapper/Connection.Config.*.Mapper.pas` | Mapeamento formato → `TConnection` |
| `Static/Connection.Config.*.pas` | Loaders `TConnectionConfigINI`, `TConnectionConfigJSON`, … |
| `Adapters/Connection.Config.Adapter.*.pas` | `IConnectionConfig` por formato |

## Loaders (`Static/`)

Todos herdam de `TConnectionConfigLoader` (`ConfigFormat`, `LoadFromFile`, `Load`, e `LoadFromObject` quando suportado).

| Classe | Entrada típica |
|--------|----------------|
| `TConnectionConfigINI` | Arquivo INI, texto INI, `LoadFromObject` com `TConnectionIniDocumentRef` |
| `TConnectionConfigJSON` | Arquivo/texto JSON; objeto em memória: `LoadFromJSONObject` ou `LoadFromObject` com `TConnectionJsonDocumentRef` |
| `TConnectionConfigXML` | Arquivo/texto XML; `LoadFromDocument(IXMLDocument)`; `LoadFromObject` com `TConnectionXmlDocumentRef` |
| `TConnectionConfigYAML` | Arquivo/texto YAML; `LoadFromObject` com `TConnectionYamlDocumentRef` |
| `TConnectionConfigTOML` | Arquivo/texto TOML; `LoadFromTable`; `LoadFromObject` com `TConnectionTomlDocumentRef` |

**Padrão uniforme:** `LoadFromObject` em todos os formatos aceita apenas instâncias de `TConnection*DocumentRef` (`Connection.Config.DocumentRefs`), cada uma com campo `Document` do tipo nativo (INI/JSON/XML/TOML) ou `IYamlDocument` no YAML.

## Mapper

| Unit | Classe |
|------|--------|
| `Connection.Config.INI.Mapper` | `TConnectionConfigIniMapper` |
| `Connection.Config.JSON.Mapper` | `TConnectionConfigJsonMapper` |
| `Connection.Config.XML.Mapper` | `TConnectionConfigXmlMapper` |
| `Connection.Config.YAML.Mapper` | `TConnectionConfigYamlMapper` |
| `Connection.Config.TOML.Mapper` | `TConnectionConfigTomlMapper` |

## `IConnectionConfig` e Factory

- **Adaptadores:** implementam `LoadFromFile`, `Load`, `LoadFromObject` delegando ao loader estático correspondente.
- **`TConnectionConfigFactory`:** `CreateForFormat`, `FromFile` (por extensão ou formato explícito), `FromString`, `FromObject`, `FromObject<T>`, `ObjectFormat`.

Extensões: `.ini`, `.json`, `.xml`, `.yaml`/`.yml`, `.toml`.

## Dependências de build

| Formato | Bibliotecas / units |
|---------|---------------------|
| INI, JSON, XML | RTL, `System.JSON` (JSON), XML (XML) |
| YAML | Neslib.Yaml |
| TOML | DelphiTOML (`TOML`, `TOML.Types`) |

## Exemplo

```delphi
uses
  Connection.Config.All,
  FireDAC.Factory;

var
  Conn: TConnection;
begin
  Conn := TConnectionConfigINI.LoadFromFile('db.ini');
  Conn := TConnectionConfigJSON.LoadFromFile('db.json');
  Conn := TConnectionConfigFactory.FromFile('db.toml').LoadFromFile('db.toml');
end;
```

## `LoadFromObject` por adaptador

| Formato | Wrapper (`Document` contém) |
|---------|------------------------------|
| INI | `TConnectionIniDocumentRef` → `TCustomIniFile` |
| JSON | `TConnectionJsonDocumentRef` → `TJSONObject` |
| XML | `TConnectionXmlDocumentRef` → `TXMLDocument` |
| YAML | `TConnectionYamlDocumentRef` → `IYamlDocument` |
| TOML | `TConnectionTomlDocumentRef` → `TTOMLTable` |

`TConnectionConfigFactory.ObjectFormat` infere o formato apenas a partir desses tipos Ref.

Para JSON em memória (incluindo `args`), construa `TConnectionJsonDocumentRef.Create(Obj)` e passe ao adaptador ou a `LoadFromObject`.
