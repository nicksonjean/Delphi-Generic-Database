# Masks

Máscaras de digitação em tempo real para `TEdit` (FMX) — sem estado externo, sem dependência de banco, sem OpenSSL.

---

## Visão geral

`TMasks` é um `record` utilitário com métodos estáticos (`class ... static`) que configuram completamente um `TEdit` para aceitar apenas o formato desejado, caractere a caractere, durante a digitação. Não usa `TMaskEdit`, não depende de `System.MaskUtils` e não deixa o campo em estado inválido em nenhum momento.

```delphi
uses Masks;

TMasks.SetupCPF(EditCPF);
TMasks.SetupDate4D(EditNascimento);
TMasks.SetupMoney(EditValor, 2, 'R$');
```

---

## Como funciona

### Motor central — `ApplyPattern`

O coração da unidade é um único algoritmo privado que substitui todos os `case Length of` com dezenas de chamadas `FormatMaskText`:

```
APattern: '000.000.000-00'
           ↑            ↑
           '0' = slot   outros chars = separador literal
```

O algoritmo percorre o template uma única vez:
- `'0'` → consome o próximo dígito/char da entrada
- qualquer outro char → insere como separador literal, apenas se ainda houver entrada a consumir depois

**Resultado:** a string formatada cresce naturalmente com a digitação e encolhe corretamente no backspace — sem `case`, sem `FormatMaskText`, sem perda de dígito em transições de grupo.

### Handlers genéricos

Toda a lógica de `OnKeyDown` é centralizada em dois handlers privados:

| Handler | Filtro de entrada | Extração |
|---|---|---|
| `SetupNumericMask` | `['0'..'9']` | `TString.OnlyNumeric` |
| `SetupAlphaMask` | `['0'..'9','a'..'z','A'..'Z']` | `TString.OnlyAlphaNumeric` |

Ambos gerenciam: filtro de tecla inválida, extração de dígitos brutos, backspace (remove último dígito), limite máximo e formatação via `ApplyPattern`.

---

## API pública

### Setup completo

Configura `TextPrompt`, `KeyboardType` e conecta o `OnKeyDown`. Chamada única na criação do formulário.

| Método | Formato | Max dígitos | Exemplo |
|---|---|---|---|
| `SetupCPF` | `000.000.000-00` | 11 | `123.456.789-09` |
| `SetupCNPJ` | `00.000.000/0000-00` | 14 | `12.345.678/0001-95` |
| `SetupCEP` | `00.000-000` | 8 | `01.310-100` |
| `SetupFone` | `(00) 00000-0000` | 11 | `(11) 98765-4321` |
| `SetupSerial` | `000000-00000-0000-00000-0000` | 24 | `A1B2C3-D4E5F-6789-GHIJK-LMNO` |
| `SetupMonthYear2D` | `00/00` | 4 | `03/25` |
| `SetupMonthYear4D` | `00/0000` | 6 | `03/2025` |
| `SetupDate2D` | `00/00/00` | 6 | `25/03/25` |
| `SetupDate4D` | `00/00/0000` | 8 | `25/03/2025` |
| `SetupTime` | `00:00:00` | 6 | `14:30:00` |
| `SetupMoney` | valor monetário com símbolo | — | `R$ 1.234,56` |
| `SetupFloat` | decimal com precisão livre | — | `3,1415` |

#### Parâmetros opcionais de Money e Float

```delphi
TMasks.SetupMoney(EditPreco);                        // R$, 2 casas
TMasks.SetupMoney(EditPreco, 2, 'US$');              // dólar
TMasks.SetupMoney(EditPreco, 2, '€');                // euro
TMasks.SetupFloat(EditTaxa, 4);                      // 4 casas, sem símbolo
TMasks.SetupFloat(EditTaxa, 4, '%');                 // porcentagem
```

---

### Formatadores avulsos (`SetMaskXxx`)

Aplicam a máscara diretamente sobre o conteúdo atual do `TEdit`, útil quando o campo é preenchido programaticamente ou ao carregar dados do banco:

```delphi
EditCPF.Text := '12345678909';
TMasks.SetMaskCPF(EditCPF);
// EditCPF.Text = '123.456.789-09'
```

| Método | Entrada esperada |
|---|---|
| `SetMaskCPF(AEdit)` | dígitos brutos em `AEdit.Text` |
| `SetMaskCNPJ(AEdit)` | dígitos brutos |
| `SetMaskCEP(AEdit)` | dígitos brutos |
| `SetMaskFone(AEdit)` | dígitos brutos |
| `SetMaskSerial(AEdit)` | alfanumérico bruto |
| `SetMaskDate4D(AEdit, Key)` | dígitos brutos; Key=0 aplica sempre |
| `SetMaskMoneyKeyDown` / `SetMaskMoneyKeyUp` | chamada via eventos |
| `SetMaskFloatKeyDown` | chamada via evento `OnKeyDown` |

---

### Filtros avulsos

Bloqueiam caracteres inválidos num `OnKeyDown` externo, sem configurar o campo completo:

```delphi
procedure TForm1.EditCodigoKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  TMasks.FilterNumericOnly(Char(KeyChar), Key);
end;
```

| Método | Permite |
|---|---|
| `FilterNumericOnly` | `0–9`, backspace, delete, navegação |
| `FilterAlphaNumericOnly` | `0–9`, `a–z`, `A–Z`, backspace, delete, navegação |

---

## Exemplos de uso

### CPF em formulário de cadastro

```delphi
procedure TFormCadastro.FormCreate(Sender: TObject);
begin
  TMasks.SetupCPF(EditCPF);
  TMasks.SetupDate4D(EditNascimento);
  TMasks.SetupFone(EditTelefone);
  TMasks.SetupCEP(EditCEP);
end;
```

### Carregando dado do banco

```delphi
EditCNPJ.Text := DataSet.FieldByName('CNPJ').AsString; // '12345678000195'
TMasks.SetMaskCNPJ(EditCNPJ);
// Exibe: '12.345.678/0001-95'
```

### Campo de valor com símbolo customizado

```delphi
TMasks.SetupFloat(EditAliquota, 2, '%');
// Digitação: '5' → '% 0,05' → '% 0,50' → '% 5,00'
```

### Serial de licença alfanumérico

```delphi
TMasks.SetupSerial(EditLicenca);
// Aceita: A-Z, a-z, 0-9
// Formata: 'ABCDEF-12345-GHIJ-KLMNO-PQRS'
```

---

## Padrões internos de template

```delphi
PAT_CPF        = '000.000.000-00';
PAT_CNPJ       = '00.000.000/0000-00';
PAT_CEP        = '00.000-000';
PAT_FONE       = '(00) 00000-0000';
PAT_SERIAL     = '000000-00000-0000-00000-0000';
PAT_MONTHYR_2D = '00/00';
PAT_MONTHYR_4D = '00/0000';
PAT_DATE_2D    = '00/00/00';
PAT_DATE_4D    = '00/00/0000';
PAT_TIME       = '00:00:00';
```

Para adicionar um novo tipo de máscara, basta definir o padrão e chamar `SetupNumericMask` ou `SetupAlphaMask` com ele.

---

## Dependências

| Unidade | Motivo |
|---|---|
| `FMX.Edit` | `TEdit`, `TKeyEvent` |
| `FMX.Types` | `TVirtualKeyBoardType` |
| `System.UITypes` | constantes `vkXxx` |
| `EventDelegate` | `DelegateKeyEvent` — conecta lambdas a eventos `OnKeyDown`/`OnKeyUp` |
| `&Type.&Float` | formatação BR de monetário/float |
| `&Type.&String` | `TString.OnlyNumeric`, `TString.OnlyAlphaNumeric` |

---

## Notas de comportamento

- **Backspace** remove o último dígito bruto e reformata — nunca deixa separadores pendentes no final do campo.
- **Teclas de navegação** (`Tab`, `Esc`, `Enter`, `←→`, `Home`, `End`, `↑↓`) passam sem interferência.
- **Colar (Ctrl+V)** não é interceptado pelo `OnKeyDown` — para campos críticos, combine com `OnChange` que chame o formatador avulso correspondente.
- **SetupMoney** conecta tanto `OnKeyDown` quanto `OnKeyUp`; os demais tipos usam apenas `OnKeyDown`.
