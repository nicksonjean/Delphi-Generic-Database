{$IFNDEF CLR}
unit DriverOptions;
{$ENDIF}

{$I Dbx.inc}

interface

uses
{$IFDEF VER11P}
  DBXTypes,
{$ENDIF}
  Variants, Classes, SysUtils;

const
  coLongStrings         = 101;
  coEnableBCD           = 102;
  coTrimFixedChar       = 103;
{$IFDEF VER11P}
  coVendorLib           = 104;
  coVendorLibOSx        = 105;
{$ENDIF}
  coReconnect           = 106;
  coDBMonitorHost       = 107;
  coDBMonitorPort       = 108;
  coEnableLargeint      = 109;
  coIPVersion           = 110;
  coTrimVarChar         = 111;
  coNullForZeroDelphiDate = 112;
  coInternalName        = 201;
  coUseQuoteChar        = 202;
  coCharLength          = 203;
  coCharset             = 204;
  coIntegerPrecision    = 205;
  coSmallIntPrecision   = 206;
  coFloatPrecision      = 207;
  coBCDPrecision        = 208;
  coUseUnicode          = 209;
  coUseUnicodeMemo      = 210;
  coUnicodeEnvironment  = 211;
  coUseDateParams       = 212;
  coClobAsWideMemo      = 213;
  coUnicodeClobParams   = 214;
  coHomeName            = 215;
  coUnicodeAsNational   = 216;
  coUnknownNumberScale  = 217;
  coFetchAll            = 301;
  coPrepared            = 302;
  coParamPrefix         = 303;
  coEnableBoolean       = 304;
  coUseUTF8             = 305;
  coCommandTimeout      = 306;
  coRequiredFields      = 307;
  coIsSQLAzureEdition   = 310;
  coAttachDBFileName    = 311;
  coUseDescribeParams   = 312;
  coMultipleActiveResultSets = 313;
  coMultiSubnetFailover = 314;
  coApplicationIntent   = 315;
  coOptimizedNumerics   = 401;
  coBooleanDomainFields = 402;
  coLockTimeout         = 403;
  coForceUsingDefaultPort = 404;
  coForceUnloadClientLibrary = 405;
  coWireCompression     = 406;
  coUseSSL = 407;
  coServerPublicFile = 408;
  coServerPublicPath = 409;
  coClientCertFile = 410;
  coClientPassPhraseFile = 411;
  coClientPassPhrase = 412;
  coSchemaName          = 28; // Ord(eConnSchemaName) - does not exist in Delphi 6
  coOIDAsLargeObject    = 501;
  coExtendedFieldsInfo  = 502;
  coUnknownAsString     = 503;
  coSSLMode             = 504;
  coSSLCACert           = 505;
  coSSLCert             = 506;
  coSSLKey              = 507;
  coSSLCipherList       = 508;
  coUnpreparedExecute   = 509;
  coDetectParamTypes    = 510;
  coCursorWithHold      = 511;
  coSkipTransError      = 512;
  coProtocolVersion     = 513;
  coApplicationName     = 514;
  coUuidWithBraces      = 515;
  coASCIIDataBase       = 601;
  coBusyTimeout         = 602;
  coEnableSharedCache   = 603;
  coEncryptionKey       = 604;
  coNewEncryptionKey    = 605;
  coReadUncommitted     = 606;
  coDeferredBlobRead    = 607;
  coDeferredArrayRead   = 608;
  coDirect              = 609;
  coForceCreateDatabase = 610;
  coEncryptionAlgorithm = 611;
  coForeignKeys			    = 612;
  coDateFormat			    = 613;
  coTimeFormat			    = 614;
  coEnableLoadExtension = 615;
  coLockingMode         = 616;
  coSynchronous         = 617;
  coJournalMode         = 618;
  coIntegerAsLargeInt   = 619;

  SLongStrings          = 'LongStrings';
  SEnableBCD            = 'EnableBCD';
  SReconnect            = 'Reconnect';
  SDBMonitorHost        = 'DBMonitorHost';
  SDBMonitorPort        = 'DBMonitorPort';
  SEnableLargeint       = 'EnableLargeint';
  SIPVersion            = 'IPVersion';
  SInternalName         = 'InternalName';
  SUseQuoteChar         = 'UseQuoteChar';
  SFetchAll             = 'FetchAll';
  SCharLength           = 'CharLength';
  SPrepared             = 'Prepared';
  SParamPrefix          = 'ParamPrefix';
  STrimFixedChar        = 'TrimFixedChar';
  STrimVarChar          = 'TrimVarChar';
  SCharset              = 'Charset';
  SIntegerPrecision     = 'IntegerPrecision';
  SSmallIntPrecision    = 'SmallIntPrecision';
  SFloatPrecision       = 'FloatPrecision';
  SBCDPrecision         = 'BCDPrecision';
  SUnknownNumberScale   = 'UnknownNumberScale';
  SEnableBoolean        = 'EnableBoolean';
  SUseUnicode           = 'UseUnicode';
  SUseUnicodeMemo       = 'UseUnicodeMemo';
  SUnicodeEnvironment   = 'UnicodeEnvironment';
  SUseDateParams        = 'UseDateParams';
  SClobAsWideMemo       = 'ClobAsWideMemo';
  SUnicodeClobParams    = 'UnicodeClobParams';
  SHomeName             = 'HomeName';
  SUnicodeAsNational    = 'UnicodeAsNational';
  SCommandTimeout       = 'CommandTimeout';
  SCommandTimeout2      = 'Command Timeout';
  SRequiredFields       = 'RequiredFields';
  SOptimizedNumerics    = 'OptimizedNumerics';
  SBooleanDomainFields  = 'BooleanDomainFields';
  SLockTimeout          = 'LockTimeout';
  SForceUsingDefaultPort = 'ForceUsingDefaultPort';
  SForceUnloadClientLibrary = 'ForceUnloadClientLibrary';
  SWireCompression      = 'WireCompression';
  SUseSSL 		= 'UseSSL';
  SServerPublicFile 	= 'SSLServerPublicFile';
  SServerPublicPath 	= 'SSLServerPublicPath';
  SClientCertFile 	= 'SSLClientCertFile';
  SClientPassPhraseFile = 'SSLClientPassPhraseFile';
  SClientPassPhrase 	= 'SSLClientPassPhrase';
  SSchemaName           = 'SchemaName';
  SOIDAsLargeObject     = 'OIDAsLargeObject';
  SExtendedFieldsInfo   = 'ExtendedFieldsInfo';
  SUnknownAsString      = 'UnknownAsString';
  SSSLMode              = 'SSLMode';
  SSSLCACert            = 'SSLCACert';
  SSSLCert              = 'SSLCert';
  SSSLKey               = 'SSLKey';
  SSSLCipherList        = 'SSLCipherList';
  SUnpreparedExecute    = 'UnpreparedExecute';
  SDetectParamTypes     = 'DetectParamTypes';
  SCursorWithHold       = 'CursorWithHold';
  SSkipTransError       = 'SkipTransError';
  SProtocolVersion      = 'ProtocolVersion';
  SApplicationName      = 'ApplicationName';
  SUuidWithBraces       = 'UuidWithBraces';
  SASCIIDataBase        = 'ASCIIDataBase';
  SBusyTimeout          = 'BusyTimeout';
  SEnableSharedCache    = 'EnableSharedCache';
  SEncryptionKey        = 'EncryptionKey';
  SNewEncryptionKey     = 'NewEncryptionKey';
  SReadUncommitted      = 'ReadUncommitted';
  SDeferredBlobRead     = 'DeferredBlobRead';
  SDeferredArrayRead    = 'DeferredArrayRead';
  SDirect               = 'Direct';
  SForceCreateDatabase  = 'ForceCreateDatabase';
  SEncryptionAlgorithm  = 'EncryptionAlgorithm';
  SForeignKeys  		    = 'ForeignKeys';
  SDateFormat           = 'DateFormat';
  STimeFormat           = 'TimeFormat';
  SEnableLoadExtension  = 'EnableLoadExtension';
  SNullForZeroDelphiDate= 'NullForZeroDelphiDate';
  SAttachDBFileName     = 'AttachDBFileName';
  SUseDescribeParams    = 'UseDescribeParams';
  SLockingMode          = 'LockingMode';
  SSynchronous          = 'Synchronous';
  SJournalMode          = 'JournalMode';
  SIntegerAsLargeInt    = 'IntegerAsLargeInt';
  SMultipleActiveResultSets = 'MultipleActiveResultSets';
  SMultiSubnetFailover  = 'MultiSubnetFailover';
  SApplicationIntent    = 'ApplicationIntent';

{$IFDEF VER11P}
  HOSTNAME_KEY          = 'HostName';
  ROLENAME_KEY          = 'RoleName';
  AUTOCOMMIT_KEY        = 'AutoCommit';
  BLOCKINGMODE_KEY      = 'BlockingMode';
  WAITONLOCKS_KEY       = 'WaitOnLocks';
  COMMITRETAIN_KEY      = 'CommitRetain';
  TRANSISOLATION_KEY    = 'TransIsolation';
  SQLDIALECT_KEY        = 'SqlDialect';
  SQLSERVER_CHARSET_KEY = 'ServerCharSet';
  OSAUTHENTICATION      = 'OS Authentication';
  SERVERPORT            = 'Server Port';
  MULTITRANSENABLED     = 'Multiple Transaction';
  TRIMCHAR              = 'Trim Char';
  CUSTOM_INFO           = 'Custom String';
  CONN_TIMEOUT          = 'Connection Timeout';
  SREADCOMMITTED        = 'readcommitted';
  SREPEATREAD           = 'repeatableread';
  SDIRTYREAD            = 'dirtyread';
  SSNAPSHOT             = 'snapshot';
  SVENDORLIB            = 'VendorLib';
  SVENDORLIBOSX         = 'VendorLibOSx';
{$ENDIF}

  SEADEFAULT            = 'default';
  SEAAES128             = 'aes128';
  SEAAES192             = 'aes192';
  SEAAES256             = 'aes256';
  SEA3DES               = 'tripledes';
  SEABLOWFISH           = 'blowfish';
  SEACAST128            = 'cast128';
  SEARC4                = 'rc4';

type  
  TLiteEncryptionAlgorithm = (TripleDES, Blowfish, AES128, AES192, AES256, Cast128, RC4, Default);
  TLiteLockingMode = (ModeNormal, ModeExclusive);
  TLiteSynchronous = (SyncOff, SyncNormal, SyncFull, SyncExtra);
  TLiteJournalMode = (JournalDelete, JournalTruncate, JournalPersist, JournalMemory, JournalWAL, JournalOff, JournalDefault);

procedure ConvertOption(const Name, Value: WideString; var SQLOption: integer; var SQLOptionValue: Variant; ConvertString: boolean = False);

implementation

type
  TOptionType = (otString, otInteger, otBoolean, otCustom);

  TConvertValueFunc = function(Value: WideString): Variant;

  TOption = class
  public
    OptionType: TOptionType;
    OptionID: integer;
    PartialCompare: boolean;
    ConvertValueFunc: TConvertValueFunc;

    constructor Create(AOptionType: TOptionType; AOptionID: integer; APartialCompare: boolean = False; AConvertValueFunc: TConvertValueFunc = nil);
  end;

var
  SupportedOptions: TStringList;

{$IFDEF VER11P}
function IsolationValueConvertFunc(Value: WideString): Variant;
begin
  if LowerCase(Value) = SREPEATREAD then
    Result := Integer(xilREPEATABLEREAD)
  else
  if LowerCase(Value) = SDIRTYREAD then
    Result := Integer(xilDIRTYREAD)
  else
  if LowerCase(Value) = SSNAPSHOT then
    Result := Integer(xilSNAPSHOT)
  else
    Result := Integer(xilREADCOMMITTED);
end;
{$ENDIF}

function EncryptionAlgorithmValueConvertFunc(Value: WideString): Variant;
begin
  if LowerCase(Value) = SEA3DES then
    Result := Integer(TripleDES)
  else
  if LowerCase(Value) = SEABLOWFISH then
    Result := Integer(Blowfish)
  else
  if LowerCase(Value) = SEAAES128 then
    Result := Integer(AES128)
  else
  if LowerCase(Value) = SEAAES192 then
    Result := Integer(AES192)
  else
  if LowerCase(Value) = SEAAES256 then
    Result := Integer(AES256)
  else
  if LowerCase(Value) = SEACAST128 then
    Result := Integer(Cast128)
  else
  if LowerCase(Value) = SEARC4 then
    Result := Integer(RC4)
  else
  if LowerCase(Value) = SEADEFAULT then
    Result := Integer(Default)
  else
    Result := Integer(Default);
end;

function LockingModeConvertFunc(Value: WideString): Variant;
begin
  if LowerCase(Value) = 'normal' then
    Result := Integer(ModeNormal)
  else
  if LowerCase(Value) = 'exclusive' then
    Result := Integer(ModeExclusive)
  else
    Result := Integer(ModeExclusive);
end;

function SynchronousConvertFunc(Value: WideString): Variant;
begin
  if LowerCase(Value) = 'off' then
    Result := Integer(SyncOff)
  else
  if LowerCase(Value) = 'normal' then
    Result := Integer(SyncNormal)
  else
  if LowerCase(Value) = 'full' then
    Result := Integer(SyncFull)
  else
  if LowerCase(Value) = 'extra' then
    Result := Integer(SyncExtra)
  else
    Result := Integer(SyncOff);
end;

function JournalModeConvertFunc(Value: WideString): Variant;
begin
  if LowerCase(Value) = 'delete' then
    Result := Integer(JournalDelete)
  else
  if LowerCase(Value) = 'truncate' then
    Result := Integer(JournalTruncate)
  else
  if LowerCase(Value) = 'persist' then
    Result := Integer(JournalPersist)
  else
  if LowerCase(Value) = 'memory' then
    Result := Integer(JournalMemory)
  else
  if LowerCase(Value) = 'wal' then
    Result := Integer(JournalWAL)
  else
  if LowerCase(Value) = 'off' then
    Result := Integer(JournalOff)
  else
  if LowerCase(Value) = 'default' then
    Result := Integer(JournalDefault)
  else
    Result := Integer(JournalDefault);
end;

procedure ConvertOption(const Name, Value: WideString; var SQLOption: integer; var SQLOptionValue: Variant;
  ConvertString: boolean = False);
var
  i: integer;
  Option: TOption;
begin
  for i := 0 to SupportedOptions.Count - 1 do begin
    Option := TOption(SupportedOptions.Objects[i]);
    if (Option.PartialCompare and (Pos(SupportedOptions[i], string(Name)) > 0)) or
      (CompareText(Name, SupportedOptions[i]) = 0)
    then begin
      SQLOption := Option.OptionID;
      case Option.OptionType of
        otString:
        {$IFNDEF CLR}
          if ConvertString then
            SQLOptionValue := {$IFDEF VER16P}NativeInt{$ELSE}Integer{$ENDIF}(Value)
          else
        {$ENDIF}
            SQLOptionValue := Value;
        otInteger:
          SQLOptionValue := StrToInt(Trim(Value));
        otBoolean:
          SQLOptionValue := Integer(UpperCase(trim(Value)) = 'TRUE');
        otCustom:
          SQLOptionValue := Option.ConvertValueFunc(Value);
      end;
      Exit;
    end;
  end;

  SQLOption := 0;
  SQLOptionValue := 0;
end;

{ TOption }

constructor TOption.Create(AOptionType: TOptionType; AOptionID: integer; APartialCompare: boolean = False;
  AConvertValueFunc: TConvertValueFunc = nil);
begin
  inherited Create;

  OptionType := AoptionType;
  OptionID := AOptionID;
  PartialCompare := APartialCompare;
  ConvertValueFunc := AConvertValueFunc;
end;

procedure FreeSupportOptions();
var
  i: integer;
begin
  for i := 0 to SupportedOptions.Count - 1 do
    SupportedOptions.Objects[i].Free;

  SupportedOptions.Free;
end;

initialization
  SupportedOptions := TStringList.Create;

{$IFDEF VER11P}
  // Standard options
  SupportedOptions.AddObject(HOSTNAME_KEY, TOption.Create(otString, Integer(eConnHostName)));
  SupportedOptions.AddObject(ROLENAME_KEY, TOption.Create(otString, Integer(eConnRoleName)));
  SupportedOptions.AddObject(WAITONLOCKS_KEY, TOption.Create(otBoolean, Integer(eConnWaitOnLocks)));
  SupportedOptions.AddObject(COMMITRETAIN_KEY, TOption.Create(otBoolean, Integer(eConnCommitRetain)));
  SupportedOptions.AddObject(AUTOCOMMIT_KEY, TOption.Create(otBoolean, Integer(eConnAutoCommit)));
  SupportedOptions.AddObject(BLOCKINGMODE_KEY, TOption.Create(otBoolean, Integer(eConnBlockingMode)));
  SupportedOptions.AddObject(SQLSERVER_CHARSET_KEY, TOption.Create(otString, Integer(eConnServerCharSet)));
  SupportedOptions.AddObject(TRANSISOLATION_KEY, TOption.Create(otCustom, Integer(eConnTxnIsoLevel), True, IsolationValueConvertFunc));
  SupportedOptions.AddObject(SQLDIALECT_KEY, TOption.Create(otInteger, Integer(eConnSQLDialect)));
  SupportedOptions.AddObject(OSAUTHENTICATION, TOption.Create(otBoolean, Integer(eConnOSAuthentication)));
  SupportedOptions.AddObject(SERVERPORT, TOption.Create(otString, Integer(eConnServerPort)));
  SupportedOptions.AddObject(MULTITRANSENABLED, TOption.Create(otBoolean, Integer(eConnMultipleTransaction)));
  SupportedOptions.AddObject(TRIMCHAR, TOption.Create(otBoolean, Integer(eConnTrimChar)));
  SupportedOptions.AddObject(CUSTOM_INFO, TOption.Create(otString, Integer(eConnCustomInfo)));
  SupportedOptions.AddObject(CONN_TIMEOUT, TOption.Create(otInteger, Integer(eConnTimeOut)));
  SupportedOptions.AddObject(SVENDORLIB, TOption.Create(otString, Integer(coVendorLib)));
  SupportedOptions.AddObject(SVENDORLIBOSX, TOption.Create(otString, Integer(coVendorLibOSx)));
{$ENDIF}

  // Extended options
  SupportedOptions.AddObject(SLongStrings, TOption.Create(otBoolean, coLongStrings));
  SupportedOptions.AddObject(SEnableBCD, TOption.Create(otBoolean, coEnableBCD));
  SupportedOptions.AddObject(SReconnect, TOption.Create(otBoolean, coReconnect));
  SupportedOptions.AddObject(SDBMonitorHost, TOption.Create(otString, coDBMonitorHost));
  SupportedOptions.AddObject(SDBMonitorPort, TOption.Create(otInteger, coDBMonitorPort));
  SupportedOptions.AddObject(SEnableLargeint, TOption.Create(otBoolean, coEnableLargeint));
  SupportedOptions.AddObject(SIPVersion, TOption.Create(otString, coIPVersion));
  SupportedOptions.AddObject(SInternalName, TOption.Create(otString, coInternalName));
  SupportedOptions.AddObject(SUseQuoteChar, TOption.Create(otBoolean, coUseQuoteChar));
  SupportedOptions.AddObject(SFetchAll, TOption.Create(otBoolean, coFetchAll));
  SupportedOptions.AddObject(SCharLength, TOption.Create(otInteger, coCharLength));
  SupportedOptions.AddObject(SPrepared, TOption.Create(otBoolean, coPrepared));
  SupportedOptions.AddObject(SParamPrefix, TOption.Create(otBoolean, coParamPrefix));
  SupportedOptions.AddObject(STrimFixedChar, TOption.Create(otBoolean, coTrimFixedChar));
  SupportedOptions.AddObject(STrimVarChar, TOption.Create(otBoolean, coTrimVarChar));
  SupportedOptions.AddObject(SCharset, TOption.Create(otString, coCharset));
  SupportedOptions.AddObject(SIntegerPrecision, TOption.Create(otInteger, coIntegerPrecision));
  SupportedOptions.AddObject(SSmallIntPrecision, TOption.Create(otInteger, coSmallIntPrecision));
  SupportedOptions.AddObject(SFloatPrecision, TOption.Create(otInteger, coFloatPrecision));
  SupportedOptions.AddObject(SBCDPrecision, TOption.Create(otString, coBCDPrecision));
  SupportedOptions.AddObject(SUnknownNumberScale, TOption.Create(otInteger, coUnknownNumberScale));
  SupportedOptions.AddObject(SEnableBoolean, TOption.Create(otBoolean, coEnableBoolean));
  SupportedOptions.AddObject(SUseUnicode, TOption.Create(otBoolean, coUseUnicode));
  SupportedOptions.AddObject(SUseUnicodeMemo, TOption.Create(otBoolean, coUseUnicodeMemo));
  SupportedOptions.AddObject(SUnicodeEnvironment, TOption.Create(otBoolean, coUnicodeEnvironment));
  SupportedOptions.AddObject(SUseDateParams, TOption.Create(otBoolean, coUseDateParams));
  SupportedOptions.AddObject(SClobAsWideMemo, TOption.Create(otBoolean, coClobAsWideMemo));
  SupportedOptions.AddObject(SUnicodeClobParams, TOption.Create(otBoolean, coUnicodeClobParams));
  SupportedOptions.AddObject(SHomeName, TOption.Create(otString, coHomeName));
  SupportedOptions.AddObject(SUnicodeAsNational, TOption.Create(otBoolean, coUnicodeAsNational));
  SupportedOptions.AddObject(SCommandTimeout, TOption.Create(otInteger, coCommandTimeout));
  SupportedOptions.AddObject(SCommandTimeout2, TOption.Create(otInteger, coCommandTimeout));
  SupportedOptions.AddObject(SRequiredFields, TOption.Create(otString, coRequiredFields));
  SupportedOptions.AddObject(SOptimizedNumerics, TOption.Create(otBoolean, coOptimizedNumerics));
  SupportedOptions.AddObject(SBooleanDomainFields, TOption.Create(otBoolean, coBooleanDomainFields));
  SupportedOptions.AddObject(SLockTimeout, TOption.Create(otInteger, coLockTimeout));
  SupportedOptions.AddObject(SForceUsingDefaultPort, TOption.Create(otBoolean, coForceUsingDefaultPort));
  SupportedOptions.AddObject(SForceUnloadClientLibrary, TOption.Create(otBoolean, coForceUnloadClientLibrary));
  SupportedOptions.AddObject(SWireCompression, TOption.Create(otBoolean, coWireCompression));
  SupportedOptions.AddObject(SUseSSL, TOption.Create(otBoolean, coUseSSL));
  SupportedOptions.AddObject(SServerPublicFile, TOption.Create(otString, coServerPublicFile));
  SupportedOptions.AddObject(SServerPublicPath, TOption.Create(otString, coServerPublicPath));
  SupportedOptions.AddObject(SClientCertFile, TOption.Create(otString, coClientCertFile));
  SupportedOptions.AddObject(SClientPassPhraseFile, TOption.Create(otString, coClientPassPhraseFile));
  SupportedOptions.AddObject(SClientPassPhrase, TOption.Create(otString, coClientPassPhrase));
  SupportedOptions.AddObject(SSchemaName, TOption.Create(otString, coSchemaName));
  SupportedOptions.AddObject(SOIDAsLargeObject, TOption.Create(otBoolean, coOIDAsLargeObject));
  SupportedOptions.AddObject(SExtendedFieldsInfo, TOption.Create(otBoolean, coExtendedFieldsInfo));
  SupportedOptions.AddObject(SUnknownAsString, TOption.Create(otBoolean, coUnknownAsString));
  SupportedOptions.AddObject(SSSLMode, TOption.Create(otString, coSSLMode));
  SupportedOptions.AddObject(SSSLCACert, TOption.Create(otString, coSSLCACert));
  SupportedOptions.AddObject(SSSLCert, TOption.Create(otString, coSSLCert));
  SupportedOptions.AddObject(SSSLKey, TOption.Create(otString, coSSLKey));
  SupportedOptions.AddObject(SSSLCipherList, TOption.Create(otString, coSSLCipherList));
  SupportedOptions.AddObject(SUnpreparedExecute, TOption.Create(otBoolean, coUnpreparedExecute));
  SupportedOptions.AddObject(SDetectParamTypes, TOption.Create(otBoolean, coDetectParamTypes));
  SupportedOptions.AddObject(SCursorWithHold, TOption.Create(otBoolean, coCursorWithHold));
  SupportedOptions.AddObject(SSkipTransError, TOption.Create(otBoolean, coSkipTransError));
  SupportedOptions.AddObject(SProtocolVersion, TOption.Create(otString, coProtocolVersion));
  SupportedOptions.AddObject(SApplicationName, TOption.Create(otString, coApplicationName));
  SupportedOptions.AddObject(SUuidWithBraces, TOption.Create(otBoolean, coUuidWithBraces));
  SupportedOptions.AddObject(SASCIIDataBase, TOption.Create(otBoolean, coASCIIDataBase));
  SupportedOptions.AddObject(SBusyTimeout, TOption.Create(otInteger, coBusyTimeout));
  SupportedOptions.AddObject(SEnableSharedCache, TOption.Create(otBoolean, coEnableSharedCache));
  SupportedOptions.AddObject(SEncryptionKey, TOption.Create(otString, coEncryptionKey));
  SupportedOptions.AddObject(SNewEncryptionKey, TOption.Create(otString, coNewEncryptionKey));
  SupportedOptions.AddObject(SReadUncommitted, TOption.Create(otBoolean, coReadUncommitted));
  SupportedOptions.AddObject(SDeferredBlobRead, TOption.Create(otBoolean, coDeferredBlobRead));
  SupportedOptions.AddObject(SDeferredArrayRead, TOption.Create(otBoolean, coDeferredArrayRead));
  SupportedOptions.AddObject(SDirect, TOption.Create(otBoolean, coDirect));
  SupportedOptions.AddObject(SForceCreateDatabase, TOption.Create(otBoolean, coForceCreateDatabase));
  SupportedOptions.AddObject(SEncryptionAlgorithm, TOption.Create(otCustom, coEncryptionAlgorithm, False, EncryptionAlgorithmValueConvertFunc));
  SupportedOptions.AddObject(SForeignKeys, TOption.Create(otBoolean, coForeignKeys));
  SupportedOptions.AddObject(SDateFormat, TOption.Create(otString, coDateFormat));
  SupportedOptions.AddObject(STimeFormat, TOption.Create(otString, coTimeFormat));
  SupportedOptions.AddObject(SEnableLoadExtension, TOption.Create(otBoolean, coEnableLoadExtension));
  SupportedOptions.AddObject(SNullForZeroDelphiDate, TOption.Create(otBoolean, coNullForZeroDelphiDate));
  SupportedOptions.AddObject(SAttachDBFileName, TOption.Create(otString, coAttachDBFileName));
  SupportedOptions.AddObject(SUseDescribeParams, TOption.Create(otBoolean, coUseDescribeParams));
  SupportedOptions.AddObject(SLockingMode, TOption.Create(otCustom, coLockingMode, False, LockingModeConvertFunc));
  SupportedOptions.AddObject(SSynchronous, TOption.Create(otCustom, coSynchronous, False, SynchronousConvertFunc));
  SupportedOptions.AddObject(SJournalMode, TOption.Create(otCustom, coJournalMode, False, JournalModeConvertFunc));
  SupportedOptions.AddObject(SIntegerAsLargeInt, TOption.Create(otBoolean, coIntegerAsLargeInt));
  SupportedOptions.AddObject(SMultipleActiveResultSets, TOption.Create(otBoolean, coMultipleActiveResultSets));
  SupportedOptions.AddObject(SMultiSubnetFailover, TOption.Create(otBoolean, coMultiSubnetFailover));
  SupportedOptions.AddObject(SApplicationIntent, TOption.Create(otString, coApplicationIntent));

finalization
  FreeSupportOptions;

end.

