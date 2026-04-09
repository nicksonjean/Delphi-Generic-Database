# Mail.SChannel

Envio de e-mail via SMTP com TLS/SSL no Windows — sem OpenSSL, sem DLL externa, usando exclusivamente a API nativa **SChannel** do sistema operacional através da biblioteca `Execute.IdSSLSChannel` (tothpaul/Delphi).

---

## Por que SChannel?

A stack padrão do Indy 10 depende de `ssleay32.dll` / `libssl.dll` (OpenSSL), o que exige redistribuição de DLLs e complica o deploy. O **SChannel** é a implementação TLS nativa do Windows (a mesma usada pelo IE/Edge/WinHTTP) e está disponível em qualquer instalação Windows sem nenhuma DLL adicional.

| | OpenSSL (padrão Indy) | SChannel |
|---|---|---|
| DLL extra | `ssleay32.dll`, `libeay32.dll` | Nenhuma |
| Suporte a TLS 1.2/1.3 | Depende da versão | Nativo (Windows Update) |
| Deploy | Distribui DLLs | Só o executável |
| Plataforma | Windows, Linux, macOS | Windows only |

---

## Dependências externas

Três arquivos da biblioteca [tothpaul/Delphi](https://github.com/tothpaul/Delphi/tree/master/Indy.SChannel) são necessários:

| Arquivo | Papel |
|---|---|
| `Execute.IdSSLSChannel.pas` | Implementa `TIdSSLIOHandlerSocketSChannel`, o IOHandler plugado no Indy |
| `Execute.SChannel.pas` | Record `TSSLInfo`, transliteração da API Windows para Pascal |
| `Execute.WinSSPI.pas` | `TWinSSPI` — comunicação com a API SSPI/SChannel do Windows |

Os três já estão incluídos em `Source/Vendor/IndySChannel/`.

---

## Estrutura

### `TMailConfig` (record)

Configuração imutável do servidor SMTP. Criada uma vez e passada ao construtor de `TMailSender`.

```delphi
TMailConfig = record
  Host     : string;
  Port     : Integer;
  Username : string;
  Password : string;
  FromName : string;
  FromEmail: string;
  UseTLS   : TIdUseTLS;  // utUseExplicitTLS (587) | utUseImplicitTLS (465)
end;
```

| Campo | Descrição |
|---|---|
| `Host` | Endereço do servidor SMTP (ex: `smtp.gmail.com`) |
| `Port` | `587` para STARTTLS (explicit) · `465` para SMTPS (implicit) |
| `Username` | Usuário de autenticação (geralmente o e-mail completo) |
| `Password` | Senha ou App Password (Gmail, Outlook, etc.) |
| `FromName` | Nome exibido no campo "De:" |
| `FromEmail` | Endereço remetente |
| `UseTLS` | `utUseExplicitTLS` · `utUseImplicitTLS` · `utNoTLSSupport` |

---

### `TMailMessage` (class)

Representa uma mensagem a ser enviada. Gerencia destinatários, cópias, cópias ocultas, corpo e anexos.

```delphi
procedure AddRecipient (const AEmail: string);  // Para:
procedure AddCC        (const AEmail: string);  // Cc:
procedure AddBCC       (const AEmail: string);  // Cco:
procedure AddAttachment(const AFile : string);  // Anexo (valida FileExists)

property Subject    : string  read/write;
property Body       : string  read/write;
property IsHTML     : Boolean read/write;  // text/html ou text/plain
property Recipients : TStringList read;
property CC         : TStringList read;
property BCC        : TStringList read;
property Attachments: TStringList read;
```

`AddAttachment` lança exceção se o arquivo não existir — valide o caminho antes.

---

### `TMailSender` (class)

Gerencia a conexão SMTP e executa o envio. A conexão é aberta e fechada a cada chamada de `Send` (stateless entre envios).

```delphi
constructor Create(const AConfig: TMailConfig);
procedure   Send  (AMail: TMailMessage);
destructor  Destroy; override;
```

Internamente usa:
- `TIdSMTP` — cliente SMTP do Indy
- `TIdSSLIOHandlerSocketSChannel` — IOHandler TLS via SChannel
- Timeout de conexão e leitura: **10 segundos** (configurável em `Configure`)

---

## Uso básico

### Gmail com STARTTLS (porta 587)

```delphi
uses Mail.SChannel;

var
  Config: TMailConfig;
  Sender: TMailSender;
  Mail  : TMailMessage;
begin
  Config.Host      := 'smtp.gmail.com';
  Config.Port      := 587;
  Config.Username  := 'seuemail@gmail.com';
  Config.Password  := 'sua_app_password';    // App Password do Google
  Config.FromName  := 'Sistema XYZ';
  Config.FromEmail := 'seuemail@gmail.com';
  Config.UseTLS    := utUseExplicitTLS;

  Sender := TMailSender.Create(Config);
  try
    Mail := TMailMessage.Create;
    try
      Mail.Subject := 'Relatório diário';
      Mail.Body    := '<h1>Relatório</h1><p>Segue em anexo.</p>';
      Mail.IsHTML  := True;
      Mail.AddRecipient('destinatario@empresa.com');
      Mail.AddCC('gestor@empresa.com');
      Mail.AddAttachment('C:\Relatorios\relatorio.pdf');
      Sender.Send(Mail);
    finally
      Mail.Free;
    end;
  finally
    Sender.Free;
  end;
end;
```

### Outlook / Office 365 com SMTPS (porta 465)

```delphi
Config.Host   := 'smtp.office365.com';
Config.Port   := 587;
Config.UseTLS := utUseExplicitTLS;
```

### SMTP sem TLS (ambiente interno/local)

```delphi
Config.Port   := 25;
Config.UseTLS := utNoTLSSupport;
```

---

## Múltiplos destinatários

```delphi
Mail.AddRecipient('fulano@empresa.com');
Mail.AddRecipient('ciclano@empresa.com');
Mail.AddCC('gerente@empresa.com');
Mail.AddBCC('auditoria@empresa.com');
```

## Múltiplos anexos

```delphi
Mail.AddAttachment(TPath.Combine(TPath.GetDocumentsPath, 'nota.pdf'));
Mail.AddAttachment(TPath.Combine(TPath.GetDocumentsPath, 'planilha.xlsx'));
```

---

## Portas e modos TLS

| Porta | Modo | `UseTLS` | Observações |
|---|---|---|---|
| 25 | Sem criptografia | `utNoTLSSupport` | Uso interno / relay local |
| 587 | STARTTLS (explicit) | `utUseExplicitTLS` | Padrão recomendado |
| 465 | SMTPS (implicit) | `utUseImplicitTLS` | SSL desde o início |

---

## Tratamento de erros

`TMailSender.Send` não captura exceções internamente — toda falha (autenticação, timeout, arquivo não encontrado) é propagada para o chamador:

```delphi
try
  Sender.Send(Mail);
except
  on E: EIdSMTPReplyError do
    ShowMessage('Erro SMTP: ' + E.Message);
  on E: EIdConnectException do
    ShowMessage('Sem conexão com o servidor: ' + E.Message);
  on E: Exception do
    ShowMessage('Erro inesperado: ' + E.Message);
end;
```

---

## Dependências

| Unidade | Motivo |
|---|---|
| `IdSMTP` | Cliente SMTP (Indy 10) |
| `IdMessage` | Montagem da mensagem (`TIdMessage`) |
| `IdAttachmentFile` | Anexos de arquivo |
| `IdExplicitTLSClientServerBase` | Enum `TIdUseTLS` |
| `Execute.IdSSLSChannel` | IOHandler TLS via SChannel (sem OpenSSL) |

---

## Licença

Distribuído sob a **GNU Lesser General Public License v3** (LGPL-3.0).  
Autoria original: Nickson Jeanmerson, 2018.  
Biblioteca SChannel: [tothpaul/Delphi](https://github.com/tothpaul/Delphi/tree/master/Indy.SChannel) — licença própria do autor.
