      {$IFDEF FireDACLib}
      with Self.Connection do
      begin
        case FDriver of
          SQLITE:
            begin
              {$IFDEF MSWINDOWS}
              var FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
              FDPhysSQLiteDriverLink := ISmartPointer<TFDPhysSQLiteDriverLink>(TFDPhysSQLiteDriverLink.Create(nil));
              FDPhysSQLiteDriverLink.VendorLib := ExtractFilePath(ParamStr(0)) + 'sqlite3.dll';
//              TFDPhysSQLiteDriverLink.Create(nil).VendorLib := ExtractFilePath(ParamStr(0)) + 'sqlite3.dll';
              {$ENDIF}
              ConnectionName := 'DBSQLite';
              DriverName := 'SQLite';
              Connected := False;
              with ResourceOptions as TFDTopResourceOptions do
              begin
                KeepConnection := True;
                Persistent := True;
                SilentMode := True;
              end;
              with FetchOptions as TFDFetchOptions do
              begin
                RecordCountMode := cmVisible;
              end;
              LoginPrompt := False;
              with Params as TFDPhysSQLiteConnectionDefParams do
              begin
                BeginUpdate();
                Clear;
                DriverID := 'SQLite';
                Database := FDatabase;
                EndUpdate();
              end;
            end;
          MYSQL:
            begin
              {$IFDEF MSWINDOWS}
              var FDPhysMySQLDriverLink: TFDPhysMySQLDriverLink;
              FDPhysMySQLDriverLink := ISmartPointer<TFDPhysMySQLDriverLink>(TFDPhysMySQLDriverLink.Create(nil));
              FDPhysMySQLDriverLink.VendorLib := ExtractFilePath(ParamStr(0)) + 'libmysql.dll';
              {$ENDIF}
              ConnectionName := 'DBMySQL';
              DriverName := 'MySQL';
              Connected := False;
              with ResourceOptions as TFDTopResourceOptions do
              begin
                KeepConnection := True;
                Persistent := True;
                SilentMode := True;
                DirectExecute := True;
              end;
              with FetchOptions as TFDFetchOptions do
              begin
                RecordCountMode := cmVisible;
              end;
              LoginPrompt := False;
              with Params as TFDPhysMySQLConnectionDefParams do
              begin
                BeginUpdate();
                Clear;
                DriverID := 'MySQL';
                Server := FHost;
                Port :=  IfThen(FPort = 3306, 3306, FPort);
                Database := FDatabase;
                UserName := FUsername;
                Password := System.StrUtils.IfThen(FPassword = '', #0, FPassword);
                Compress := True;
                EndUpdate();
              end;
            end;
          FIREBIRD:
            begin
              {$IFDEF MSWINDOWS}
              var FDPhysFBDriverLink: TFDPhysFBDriverLink;
              FDPhysFBDriverLink := ISmartPointer<TFDPhysFBDriverLink>(TFDPhysFBDriverLink.Create(nil));
              FDPhysFBDriverLink.VendorLib := ExtractFilePath(ParamStr(0)) + 'libmysql.dll';
              {$ENDIF}
              ConnectionName := 'DBFirebird';
              DriverName := 'FB';
              Connected := False;
              with ResourceOptions as TFDTopResourceOptions do
              begin
                KeepConnection := True;
                Persistent := True;
                SilentMode := True;
                DirectExecute := True;
              end;
              with FetchOptions as TFDFetchOptions do
              begin
                RecordCountMode := cmVisible;
              end;
              LoginPrompt := False;
              with Params as TFDPhysFBConnectionDefParams do
              begin
                BeginUpdate();
                Clear;
                DriverID := 'FB';
                Server := FHost;
                Port := IfThen(FPort = 3050, 3050, FPort);
                Database := FDatabase;
                UserName := FUsername;
                Password := System.StrUtils.IfThen(FPassword = '', #0, FPassword);
                Protocol := ipTCPIP;
                SQLDialect := 3;
                CharacterSet := TIBCharacterSet.csUTF8;
                EndUpdate();
              end;
            end;
          INTERBASE:
            begin
              {$IFDEF MSWINDOWS}
              var FDPhysIBDriverLink: TFDPhysFBDriverLink;
              FDPhysIBDriverLink := ISmartPointer<TFDPhysFBDriverLink>(TFDPhysFBDriverLink.Create(nil));
              FDPhysIBDriverLink.VendorLib := ExtractFilePath(ParamStr(0)) + 'gds32.dll';
              {$ENDIF}
              ConnectionName := 'DBInterbase';
              DriverName := 'IB';
              Connected := False;
              with ResourceOptions as TFDTopResourceOptions do
              begin
                KeepConnection := True;
                Persistent := True;
                SilentMode := True;
                DirectExecute := True;
              end;
              with FetchOptions as TFDFetchOptions do
              begin
                RecordCountMode := cmVisible;
              end;
              LoginPrompt := False;
              with Params as TFDPhysFBConnectionDefParams do
              begin
                BeginUpdate();
                Clear;
                DriverID := 'IB';
                Server := FHost;
                Port := IfThen(FPort = 3050, 3050, FPort);
                Database := FDatabase;
                UserName := FUsername;
                Password := System.StrUtils.IfThen(FPassword = '', #0, FPassword);
                Protocol := ipTCPIP;
                SQLDialect := 3;
                CharacterSet := TIBCharacterSet.csUTF8;
                EndUpdate();
              end;
            end;
          MSSQL:
            begin
              {$IFDEF MSWINDOWS}
              var FDPhysMSSQLDriverLink: TFDPhysMSSQLDriverLink;
              FDPhysMSSQLDriverLink := ISmartPointer<TFDPhysMSSQLDriverLink>(TFDPhysMSSQLDriverLink.Create(nil));
              FDPhysMSSQLDriverLink.VendorLib := ExtractFilePath(ParamStr(0)) + 'sqlncli11.dll';
              {$ENDIF}
              ConnectionName := 'DBMSSQL';
              DriverName := 'MSSQL';
              Connected := False;
              with ResourceOptions as TFDTopResourceOptions do
              begin
                KeepConnection := True;
                Persistent := True;
                SilentMode := True;
                DirectExecute := True;
              end;
              with FetchOptions as TFDFetchOptions do
              begin
                RecordCountMode := cmVisible;
              end;
              LoginPrompt := False;
              with Params as TFDPhysMSSQLConnectionDefParams do
              begin
                BeginUpdate();
                Clear;
                DriverID := 'MSSQL';
                Server := FHost;
                Port :=  IfThen(FPort = 1433, 1433, FPort);
                Database := FDatabase;
                UserName := FUsername;
                Password := System.StrUtils.IfThen(FPassword = '', #0, FPassword);
                EndUpdate();
              end;
            end;
          POSTGRESQL:
            begin
              {$IFDEF MSWINDOWS}
              var FDPhysPgDriverLink: TFDPhysPgDriverLink;
              FDPhysPgDriverLink := ISmartPointer<TFDPhysPgDriverLink>(TFDPhysPgDriverLink.Create(nil));
              FDPhysPgDriverLink.VendorLib := ExtractFilePath(ParamStr(0)) + 'libpq.dll';
              {$ENDIF}
              ConnectionName := 'DBPostgreSQL';
              DriverName := 'PG';
              Connected := False;
              with ResourceOptions as TFDTopResourceOptions do
              begin
                KeepConnection := True;
                Persistent := True;
                SilentMode := True;
              end;
              with FetchOptions as TFDFetchOptions do
              begin
                RecordCountMode := cmVisible;
              end;
              LoginPrompt := False;
              with Params as TFDPhysPGConnectionDefParams do
              begin
                BeginUpdate();
                Clear;
                DriverID := 'PG';
                Server := FHost;
                Port := IfThen(FPort = 5432, 5432, FPort);
                Database := FDatabase;
                UserName := FUsername;
                Password := System.StrUtils.IfThen(FPassword = '', #0, FPassword);
                MetaDefSchema := FSchema;
                EndUpdate();
              end;
              ExecSQL('SET search_path TO E''' + FSchema + ''', E''public'';');
            end;
          ORACLE:
            begin
              {$IFDEF MSWINDOWS}
              var FDPhysOracleDriverLink: TFDPhysOracleDriverLink;
              FDPhysOracleDriverLink := ISmartPointer<TFDPhysOracleDriverLink>(TFDPhysOracleDriverLink.Create(nil));
              FDPhysOracleDriverLink.VendorLib := ExtractFilePath(ParamStr(0)) + 'libpq.dll';
              {$ENDIF}
              ConnectionName := 'DBOracle';
              DriverName := 'ORA';
              Connected := False;
              with ResourceOptions as TFDTopResourceOptions do
              begin
                KeepConnection := True;
                Persistent := True;
                SilentMode := True;
                DirectExecute := True;
              end;
              with FetchOptions as TFDFetchOptions do
              begin
                RecordCountMode := cmVisible;
              end;
              LoginPrompt := False;
              with Params as TFDPhysOracleConnectionDefParams do
              begin
                BeginUpdate();
                Clear;
                DriverID := 'Ora';
                Database := System.SysUtils.Format('(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=%s)(PORT=%u))(CONNECT_DATA=(SERVICE_NAME=%s)))', [FHost, IfThen(FPort = 5432, 5432, FPort), FSchema]);
                UserName := FUsername;
                Password := System.StrUtils.IfThen(FPassword = '', #0, FPassword);
                MetaDefSchema := FUsername;
                MetaCurSchema := FUsername;
                Name := FUsername;
                CharacterSet := TFDOracleCharacterSet.csUTF8;
                EndUpdate();
              end;
            end;
        end;
      end;
      {$ENDIF}