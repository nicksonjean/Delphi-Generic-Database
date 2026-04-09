{
  Mail.SChannel.
  ------------------------------------------------------------------------------
  Objetivo: Enviar emails via SMTP com TLS/SSL usando SChannel (Windows), sem OpenSSL.
  Usa a biblioteca Execute.IdSSLSChannel (tothpaul/Delphi) para TLS/SSL usando SChannel,
  que pode ser encontrado em: https://github.com/tothpaul/Delphi/tree/master/Indy.SChannel,
  iremos precisar apenas de 3 arquivos: Execute.IdSSLSChannel.pas, Execute.SChannel.pas e Execute.WinSSPI.pas.
  Execute.IdSSLSChannel.pas é o arquivo principal que contém a classe TIdSSLIOHandlerSocketSChannel,
  Execute.SChannel.pas é o arquivo que contém o record TSSLInfo, translitera a api windows para pascal, usando a classe TWinSSPI,
  Execute.WinSSPI.pas é o arquivo que contém a classe TWinSSPI, responsável pela comunicação com a api do windows para TLS/SSL,
  para mais informações, consulte o readme.md da biblioteca no repositório do github.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson, 2018.
  ------------------------------------------------------------------------------
  Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la
  sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a versão 3.29 da Licença, ou (a seu critério)
  qualquer versão posterior.
  Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM
  NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU
  ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor
  do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT)
  Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto
  com esta biblioteca; se não, escreva para a Free Software Foundation, Inc.,
  no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  Você também pode obter uma copia da licença em:
  http://www.opensource.org/licenses/lgpl-license.php
}

unit Mail.SChannel;

interface

uses
  System.SysUtils,
  System.Classes,
  IdSMTP,
  IdMessage,
  IdAttachmentFile,
  IdExplicitTLSClientServerBase,
  Execute.IdSSLSChannel;

type
  TMailConfig = record
    Host: string;
    Port: Integer;
    Username: string;
    Password: string;
    FromName: string;
    FromEmail: string;
    UseTLS: TIdUseTLS; // utUseExplicitTLS (587) | utUseImplicitTLS (465)
  end;

  TMailMessage = class
  private
    FRecipients: TStringList;
    FCC: TStringList;
    FBCC: TStringList;
    FAttachments: TStringList;
    FSubject: string;
    FBody: string;
    FIsHTML: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddRecipient(const AEmail: string);
    procedure AddCC(const AEmail: string);
    procedure AddBCC(const AEmail: string);
    procedure AddAttachment(const AFile: string);

    property Subject: string read FSubject write FSubject;
    property Body: string read FBody write FBody;
    property IsHTML: Boolean read FIsHTML write FIsHTML;
    
    property Recipients: TStringList read FRecipients;
    property CC: TStringList read FCC;
    property BCC: TStringList read FBCC;
    property Attachments: TStringList read FAttachments;
  end;

  TMailSender = class
  private
    FSMTP: TIdSMTP;
    FSSL: TIdSSLIOHandlerSocketSChannel;
    FConfig: TMailConfig;

    procedure Configure;
  public
    constructor Create(const AConfig: TMailConfig);
    destructor Destroy; override;

    procedure Send(AMail: TMailMessage);
  end;

implementation

{ TMailMessage }

constructor TMailMessage.Create;
begin
  inherited Create;
  FRecipients := TStringList.Create;
  FCC := TStringList.Create;
  FBCC := TStringList.Create;
  FAttachments := TStringList.Create;
end;

destructor TMailMessage.Destroy;
begin
  FRecipients.Free;
  FCC.Free;
  FBCC.Free;
  FAttachments.Free;
  inherited;
end;

procedure TMailMessage.AddRecipient(const AEmail: string);
begin
  FRecipients.Add(AEmail);
end;

procedure TMailMessage.AddCC(const AEmail: string);
begin
  FCC.Add(AEmail);
end;

procedure TMailMessage.AddBCC(const AEmail: string);
begin
  FBCC.Add(AEmail);
end;

procedure TMailMessage.AddAttachment(const AFile: string);
begin
  if FileExists(AFile) then
    FAttachments.Add(AFile)
  else
    raise Exception.Create('Arquivo não encontrado: ' + AFile);
end;

{ TMailSender }

constructor TMailSender.Create(const AConfig: TMailConfig);
begin
  inherited Create;

  FConfig := AConfig;

  FSMTP := TIdSMTP.Create(nil);
  FSSL := TIdSSLIOHandlerSocketSChannel.Create(nil);

  Configure;
end;

destructor TMailSender.Destroy;
begin
  if FSMTP.Connected then
    FSMTP.Disconnect;

  FSMTP.Free;
  FSSL.Free;

  inherited;
end;

procedure TMailSender.Configure;
begin
  // TLS via SChannel (Windows), sem OpenSSL — Execute.IdSSLSChannel (tothpaul/Delphi).

  // SMTP
  FSMTP.IOHandler := FSSL;
  FSMTP.Host := FConfig.Host;
  FSMTP.Port := FConfig.Port;
  FSMTP.Username := FConfig.Username;
  FSMTP.Password := FConfig.Password;
  FSMTP.UseTLS := FConfig.UseTLS;

  // Timeouts
  FSMTP.ConnectTimeout := 10000;
  FSMTP.ReadTimeout := 10000;
end;

procedure TMailSender.Send(AMail: TMailMessage);
var
  Msg: TIdMessage;
  I: Integer;
begin
  Msg := TIdMessage.Create(nil);
  try
    // Cabeçalho
    Msg.From.Name := FConfig.FromName;
    Msg.From.Address := FConfig.FromEmail;
    Msg.Subject := AMail.Subject;

    // Destinatários (TIdEmailAddressList não aceita Assign de TStringList)
    Msg.Recipients.Clear;
    for I := 0 to AMail.Recipients.Count - 1 do
      if Trim(AMail.Recipients[I]) <> '' then
        Msg.Recipients.Add.Text := Trim(AMail.Recipients[I]);
    Msg.CCList.Clear;
    for I := 0 to AMail.CC.Count - 1 do
      if Trim(AMail.CC[I]) <> '' then
        Msg.CCList.Add.Text := Trim(AMail.CC[I]);
    Msg.BccList.Clear;
    for I := 0 to AMail.BCC.Count - 1 do
      if Trim(AMail.BCC[I]) <> '' then
        Msg.BccList.Add.Text := Trim(AMail.BCC[I]);

    // Corpo
    if AMail.IsHTML then
    begin
      Msg.ContentType := 'text/html; charset=UTF-8';
      Msg.Body.Text := AMail.Body;
    end
    else
    begin
      Msg.ContentType := 'text/plain; charset=UTF-8';
      Msg.Body.Text := AMail.Body;
    end;

    // Anexos
    for I := 0 to AMail.Attachments.Count - 1 do
      TIdAttachmentFile.Create(Msg.MessageParts, AMail.Attachments[I]);

    // Envio
    FSMTP.Connect;
    try
      FSMTP.Send(Msg);
    finally
      FSMTP.Disconnect;
    end;

  finally
    Msg.Free;
  end;
end;

end.