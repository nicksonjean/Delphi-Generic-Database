# `Source\Connector`

Camada de alto nível para consumir `Connection` + `QueryBuilder` e expor uma API simplificada de conector, com suporte a opções (`Options.*`) para parâmetros extras.

## Units

- **`Connector` / `Connector.Types`**: implementação e tipos auxiliares.
- **`Connector.Intf`**: interface marcadora (contrato/documentação).
- **`Options\`**: `Options.Intf` (marcadora) + implementações (`Options.Integer`, `Options.Array`, `Options.JSON`).

## Observação sobre as interfaces marcadoras

As interfaces em `Connector.Intf` e `Options.Intf` são **marcadoras** (GUID + contrato conceitual). As classes concretas são baseadas em `TObject`, então **não implementam** `IUnknown`/COM automaticamente; use os tipos concretos (`TConnector`, etc.) no código.

