# `Source\SmartPointer`

Helpers de **RAII / guard** para gerenciamento de ciclo de vida em Delphi usando *records* e *interfaces* como âncora de destruição.

## Units

- **`SmartPointer`**: `TSmartPointer<T>` com propriedade `Ref`.
- **`SmartPointer.RefGuard`**: guarda interno usado por `TSmartPointer<T>` (libera via interface quando aplicável, senão `Free`).
- **`SmartPointer.Intf`**: `ISmartPointer<T>` (record) com conversões implícitas.
- **`SmartPointer.Guard`** / **`SmartPointer.Guard.Intf`**: implementação do guard (`TGuard`) e interface marcadora (`IGuard`).

## Agregador

- **`SmartPointer.All`** (`SmartPointer.All.pas`): um único `uses SmartPointer.All` puxa todas as units públicas.

