      {$IFDEF ZeOSLib}
      with Self.Connection do
      begin
        case FDriver of
          SQLITE:
            begin
              {$IFDEF MSWINDOWS}
              LibraryLocation := ExtractFilePath(ParamStr(0)) + 'sqlite3.dll';
              {$ENDIF}
              Protocol := 'sqlite';
              DataBase := FDatabase;
            end;
          MYSQL:
            begin
              {$IFDEF MSWINDOWS}
              LibraryLocation := ExtractFilePath(ParamStr(0)) + 'libmysql.dll';
              {$ENDIF}
              HostName := FHost;
              Protocol := 'mysql';
              Port     := IfThen(FPort = 3306, 3306, FPort);
              Database := FDatabase;
              User     := FUsername;
              Password := System.StrUtils.IfThen(FPassword = '', #0, FPassword);
              AutoCommit := False;
              Properties.Clear;
              Properties.Add('CLIENT_MULTI_STATEMENTS=1');
              Properties.Add('controls_cp=GET_ACP');
            end;
          FIREBIRD:
            begin
              {$IFDEF MSWINDOWS}
              LibraryLocation := ExtractFilePath(ParamStr(0)) + 'fbclient.dll';
              {$ENDIF}
              HostName := FHost;
              Protocol := 'firebird-3.0';
              Port     := IfThen(FPort = 3050, 3050, FPort);
              Database := FDatabase;
              User     := FUsername;
              Password := System.StrUtils.IfThen(FPassword = '', #0, FPassword);
              AutoCommit := False;
              Properties.Clear;
              Properties.Add('CLIENT_MULTI_STATEMENTS=1');
              Properties.Add('controls_cp=GET_ACP');
            end;
          INTERBASE:
            begin
              {$IFDEF MSWINDOWS}
              LibraryLocation := ExtractFilePath(ParamStr(0)) + 'gds32.dll';
              {$ENDIF}
              HostName := FHost;
              Protocol := 'interbase';
              Port     := IfThen(FPort = 3050, 3050, FPort);
              Database := FDatabase;
              User     := FUsername;
              Password := System.StrUtils.IfThen(FPassword = '', #0, FPassword);
              AutoCommit := False;
              Properties.Clear;
              Properties.Add('CLIENT_MULTI_STATEMENTS=1');
              Properties.Add('controls_cp=GET_ACP');
            end;
          MSSQL:
            begin
              {$IFDEF MSWINDOWS}
              LibraryLocation := ExtractFilePath(ParamStr(0)) + 'sybdb.dll';
              {$ENDIF}
              HostName := FHost;
              Protocol := 'FreeTDS_MsSQL>=2005';
              Port     := IfThen(FPort = 1433, 1433, FPort);
              Database := FDatabase;
              User     := FUsername;
              Password := System.StrUtils.IfThen(FPassword = '', #0, FPassword);
              AutoCommit := False;
              Properties.Clear;
              Properties.Add('CLIENT_MULTI_STATEMENTS=1');
              Properties.Add('trusted=yes');
              Properties.Add('ntauth=true');
              Properties.Add('secure=true');
              Properties.Add('AutoEncodeStrings=ON');
              Properties.Add('controls_cp=GET_ACP');
            end;
          POSTGRESQL:
            begin
              {$IFDEF MSWINDOWS}
              LibraryLocation := ExtractFilePath(ParamStr(0)) + 'libpq.dll';
              {$ENDIF}
              HostName := FHost;
              Protocol := 'postgresql';
              Port     := IfThen(FPort = 5432, 5432, FPort);
              Database := FDatabase;
              Catalog  := FSchema;
              User     := FUsername;
              Password := System.StrUtils.IfThen(FPassword = '', #0, FPassword);
              AutoCommit := False;
              Properties.Clear;
              Properties.Add('CLIENT_MULTI_STATEMENTS=1');
              Properties.Add('controls_cp=GET_ACP');
            end;
          ORACLE:
            begin
              {$IFDEF MSWINDOWS}
              LibraryLocation := ExtractFilePath(ParamStr(0)) + 'oci.dll';
              {$ENDIF}
              Database := System.SysUtils.Format('%s/%s', [FHost, FSchema]);
              HostName := FSchema;
              Catalog  := '';
              Port     := IfThen(FPort = 1521, 1521, FPort);
              User := FUsername;
              Password := System.StrUtils.IfThen(FPassword = '', #0, FPassword);
              Protocol := 'oracle';
              AutoCommit := False;
              Properties.Clear;
              Properties.Add('codepage=utf8');
              Properties.Add('charset=utf8');
            end;
        end;
      end;
      {$ENDIF}