{$IFDEF dbExpress} //Condição
  {$DEFINE dbExpressLib} //Constante
  {$IFDEF DBXDevart} //Condição
    {$DEFINE DBXDevartLib} //Constante
  {$ENDIF}
{$ENDIF}
{$IFDEF ZeOS} //Condição
  {$DEFINE ZeOSLib} //Constante
{$ENDIF}
{$IFDEF FireDAC} //Condição
  {$DEFINE FireDACLib} //Constante
{$ENDIF}