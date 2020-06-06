{$IFDEF dbExpress}
  {$DEFINE dbExpressLib}
  {$DEFINE DBXDevart}
  {$IFDEF DBXDevart}
    {$DEFINE DBXDevartLib}
  {$ENDIF}
{$ENDIF}
{$IFDEF ZeOS}
  {$DEFINE ZeOSLib}
{$ENDIF}
{$IFDEF FireDAC}
  {$DEFINE FireDACLib}
{$ENDIF}