{$I CNC.Default.inc}

{$IF DEFINED(dbExpressLib) OR DEFINED(ZeOSLib)}
TClientDataSet
{$ENDIF}
{$IF DEFINED(FireDACLib)}
TFDMemTable
{$ENDIF}