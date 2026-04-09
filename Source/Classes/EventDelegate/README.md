# EventDelegate

Converte procedures anônimas (lambdas / closures) em handlers compatíveis com os eventos `TNotifyEvent`, `TKeyEvent` e `TItemViewEvent` do FMX — eliminando a necessidade de criar métodos de classe dedicados para cada evento simples.

---

## O problema que resolve

Em Delphi FMX, eventos como `OnClick`, `OnKeyDown` e `OnItemClick` esperam um ponteiro de método (`of object`). Isso obriga a declarar um método na classe do formulário para cada evento que se queira tratar, mesmo quando a lógica é trivial:

```delphi
// Sem EventDelegate — método obrigatório na classe
procedure TForm1.ButtonClickHandler(Sender: TObject);
begin
  ShowMessage('Clicado');
end;

// Na criação:
Button.OnClick := ButtonClickHandler;
```

Com `EventDelegate`, a lógica fica inline, no local onde faz sentido, sem poluir a declaração da classe:

```delphi
// Com EventDelegate — sem método na classe
Button.OnClick := DelegateEvent(Button, procedure(Sender: TObject)
begin
  ShowMessage('Clicado');
end);
```

---

## Como funciona

`DelegateEvent` (e seus irmãos) cria internamente um `TComponent` filho do `Owner` informado. Esse componente armazena a procedure anônima e expõe um método `of object` convencional. O ciclo de vida do wrapper é gerenciado pelo `Owner` — quando o componente pai é destruído, o wrapper é destruído junto, sem vazamento de memória.

```
Procedure anônima
       ↓
 TNotifyEventWrapper (TComponent, Owner = AEdit/AButton/...)
       ↓ método publicado
 TNotifyEvent  ←  atribuído ao campo de evento
```

---

## API

### `DelegateEvent`

Converte uma procedure anônima em `TNotifyEvent` (`OnClick`, `OnChange`, `OnEnter`, `OnExit`, etc.).

```delphi
function DelegateEvent(
  Owner: TComponent;
  Proc : TNotifyEventReference   // reference to procedure(Sender: TObject)
): TNotifyEvent;
```

**Uso:**

```delphi
Edit.OnChange := DelegateEvent(Edit, procedure(Sender: TObject)
begin
  Label.Text := TEdit(Sender).Text;
end);
```

---

### `DelegateKeyEvent`

Converte uma procedure anônima em `TKeyEvent` (`OnKeyDown`, `OnKeyUp`).

```delphi
function DelegateKeyEvent(
  Owner: TComponent;
  Proc : TNofifyKeyEventReference
    // reference to procedure(Sender: TObject; var Key: Word;
    //                        var KeyChar: WideChar; Shift: TShiftState)
): TKeyEvent;
```

**Uso:**

```delphi
Edit.OnKeyDown := DelegateKeyEvent(Edit,
  procedure(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState)
  begin
    if Key = vkReturn then
      ProcessarEntrada;
  end);
```

---

### `DelegateItemViewEvent`

Converte uma procedure anônima no tipo `TItemViewEvent` usado pelo `TListView` (`OnItemClick`, `OnItemChange`).

```delphi
function DelegateItemViewEvent(
  Owner: TComponent;
  Proc : TNotifyItemViewEventReference
    // reference to procedure(const Sender: TObject; const AItem: TListViewItem)
): TItemViewEvent;
```

**Uso:**

```delphi
ListView.OnItemClick := DelegateItemViewEvent(ListView,
  procedure(const Sender: TObject; const AItem: TListViewItem)
  begin
    ShowMessage('Item: ' + AItem.Text);
  end);
```

---

## Tipos declarados

| Tipo | Assinatura |
|---|---|
| `TNotifyEventReference` | `reference to procedure(Sender: TObject)` |
| `TNofifyKeyEventReference` | `reference to procedure(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState)` |
| `TItemViewEvent` | `procedure(const Sender: TObject; const AItem: TListViewItem) of object` |
| `TNotifyItemViewEventReference` | `reference to procedure(const Sender: TObject; const AItem: TListViewItem)` |

---

## Exemplos práticos

### Configurar múltiplos campos inline

```delphi
procedure TFormCadastro.FormCreate(Sender: TObject);
begin
  EditNome.OnChange := DelegateEvent(EditNome, procedure(Sender: TObject)
  begin
    BtnSalvar.Enabled := Trim(TEdit(Sender).Text) <> '';
  end);

  EditSenha.OnKeyDown := DelegateKeyEvent(EditSenha,
    procedure(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState)
    begin
      if Key = vkReturn then BtnLogin.OnClick(BtnLogin);
    end);
end;
```

### Captura de variáveis do escopo (closure)

A procedure anônima captura variáveis do escopo externo normalmente:

```delphi
var
  Contador: Integer;
begin
  Contador := 0;
  Button.OnClick := DelegateEvent(Button, procedure(Sender: TObject)
  begin
    Inc(Contador);
    Button.Text := Format('Cliques: %d', [Contador]);
  end);
end;
```

### Uso em TMasks (caso interno)

`EventDelegate` é a base que permite ao `TMasks` configurar `OnKeyDown`/`OnKeyUp` com closures que capturam o padrão e os parâmetros de formatação:

```delphi
AEdit.OnKeyDown := DelegateKeyEvent(AEdit,
  procedure(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState)
  begin
    // APattern e AMaxDigits são capturados do escopo de SetupNumericMask
    if Length(Digits) >= AMaxDigits then begin KeyChar := #0; Key := 0; Exit; end;
    TEdit(Sender).Text := ApplyPattern(Digits + KeyChar, APattern);
  end);
```

---

## Ciclo de vida

O `Owner` passado para `DelegateEvent` é o responsável pelo wrapper. Regra prática: use sempre o componente que receberá o evento como `Owner`:

```delphi
// Correto — Button destrói o wrapper quando for destruído
Button.OnClick := DelegateEvent(Button, ...);

// Correto — Form como dono quando o handler precisa sobreviver à troca de controle
Button.OnClick := DelegateEvent(Self, ...);

// Evitar — Owner nil exige Free manual
Button.OnClick := DelegateEvent(nil, ...);  // vazamento!
```

---

## Dependências

| Unidade | Motivo |
|---|---|
| `FMX.Types` | `TKeyEvent` |
| `FMX.Controls` | base de controles FMX |
| `FMX.ListView.Types` | `TListViewItem` |
| `FMX.ListView.Appearances` | tipos de aparência do ListView |
| `System.Classes` | `TComponent`, `TNotifyEvent` |
| `System.UITypes` | `TShiftState` |
