
//////////////////////////////////////////////////
//  DB Access Components
//  Copyright © 1998-2015 Devart. All right reserved.
//////////////////////////////////////////////////

type
  TIDEInfo = record
    Name: string;
    Version: integer;
    BdsVersion: Integer;
    PackageSuffix: string;
    RegistryKey: string;
    DSManRegistryKey: string;
  end;

  TIDEVer = (ivLazarus, ivCB5, ivCB6, ivD5, ivD6, ivD7, ivD2005, ivD2006, ivD2007, ivD2009, ivD2010, ivDXE, ivDXE2, ivDXE3, ivDXE4, ivDXE5, ivDXE6, ivDXE7, ivDXE8);

const
  IDEInfos: array [TIDEVer] of TIDEInfo =
  (
    (
      Name: 'Lazarus';
      Version: 1;
      BdsVersion: 0;
      PackageSuffix: '10';
      RegistryKey: '';
      DSManRegistryKey: '';
    ),
    (
      Name: 'C++Builder 5';
      Version: 5;
      BdsVersion: 0;
      PackageSuffix: '50';
      RegistryKey: 'Software\Borland\C++Builder\5.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\C++Builder\5.0';
    ),
    (
      Name: 'C++Builder 6';
      Version: 6;
      BdsVersion: 0;
      PackageSuffix: '60';
      RegistryKey: 'Software\Borland\C++Builder\6.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\C++Builder\6.0';
    ),
    (
      Name: 'Delphi 5';
      Version: 5;
      BdsVersion: 0;
      PackageSuffix: '50';
      RegistryKey: 'Software\Borland\Delphi\5.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\Delphi\5.0';),
    (
      Name: 'Delphi 6';
      Version: 6;
      BdsVersion: 0;
      PackageSuffix: '60';
      RegistryKey: 'Software\Borland\Delphi\6.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\Delphi\6.0';
    ),
    (
      Name: 'Delphi 7';
      Version: 7;
      BdsVersion: 0;
      PackageSuffix: '70';
      RegistryKey: 'Software\Borland\Delphi\7.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\Delphi\7.0';
    ),
    (
      Name: 'Delphi 2005';
      Version: 9;
      BdsVersion: 3;
      PackageSuffix: '90';
      RegistryKey: 'Software\Borland\BDS\3.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\BDS\3.0';
    ),
    (
      Name: 'Delphi 2006';
      Version: 10;
      BdsVersion: 4;
      PackageSuffix: '100';
      RegistryKey: 'Software\Borland\BDS\4.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\BDS\4.0';
    ),
    (
      Name: 'RAD Studio 2007';
      Version: 11;
      BdsVersion: 5;
      PackageSuffix: '105';
      RegistryKey: 'Software\Borland\BDS\5.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\BDS\5.0';
    ),
    (
      Name: 'RAD Studio 2009';
      Version: 12;
      BdsVersion: 6;
      PackageSuffix: '120';
      RegistryKey: 'Software\CodeGear\BDS\6.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\BDS\6.0';
    ),
    (
      Name: 'RAD Studio 2010';
      Version: 14;
      BdsVersion: 7;
      PackageSuffix: '140';
      RegistryKey: 'Software\CodeGear\BDS\7.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\BDS\7.0';
    ),
    (
      Name: 'RAD Studio XE';
      Version: 15;
      BdsVersion: 8;
      PackageSuffix: '150';
      RegistryKey: 'Software\Embarcadero\BDS\8.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\BDS\8.0';
    ),
    (
      Name: 'RAD Studio XE2';
      Version: 16;
      BdsVersion: 9;
      PackageSuffix: '160';
      RegistryKey: 'Software\Embarcadero\BDS\9.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\BDS\9.0';
    ),
    (
      Name: 'RAD Studio XE3';
      Version: 17;
      BdsVersion: 10;
      PackageSuffix: '170';
      RegistryKey: 'Software\Embarcadero\BDS\10.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\BDS\10.0';
    ),
    (
      Name: 'RAD Studio XE4';
      Version: 18;
      BdsVersion: 11;
      PackageSuffix: '180';
      RegistryKey: 'Software\Embarcadero\BDS\11.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\BDS\11.0';
    ),
    (
      Name: 'RAD Studio XE5';
      Version: 19;
      BdsVersion: 12;
      PackageSuffix: '190';
      RegistryKey: 'Software\Embarcadero\BDS\12.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\BDS\12.0';
    ),
    (
      Name: 'RAD Studio XE6';
      Version: 20;
      BdsVersion: 14;
      PackageSuffix: '200';
      RegistryKey: 'Software\Embarcadero\BDS\14.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\BDS\14.0';
    ),
    (
      Name: 'RAD Studio XE7';
      Version: 21;
      BdsVersion: 15;
      PackageSuffix: '210';
      RegistryKey: 'Software\Embarcadero\BDS\15.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\BDS\15.0';
    ),
    (
      Name: 'RAD Studio XE8';
      Version: 22;
      BdsVersion: 16;
      PackageSuffix: '220';
      RegistryKey: 'Software\Embarcadero\BDS\16.0';
      DSManRegistryKey: 'Software\Devart\DataSetManager\BDS\16.0';
    )
  );

{$IFDEF D5}
  IDEVer: TIDEVer = ivD5;
{$ENDIF}
{$IFDEF D6}
  IDEVer: TIDEVer = ivD6;
{$ENDIF}
{$IFDEF VER7}
  IDEVer: TIDEVer = ivD7;
{$ENDIF}
{$IFDEF VER9}
  IDEVer: TIDEVer = ivD2005;
{$ENDIF}
{$IFDEF VER10}
  IDEVer: TIDEVer = ivD2006;
{$ENDIF}
{$IFDEF VER11}
  IDEVer: TIDEVer = ivD2007;
{$ENDIF}
{$IFDEF VER12}
  IDEVer: TIDEVer = ivD2009;
{$ENDIF}
{$IFDEF VER14}
  IDEVer: TIDEVer = ivD2010;
{$ENDIF}
{$IFDEF VER15}
  IDEVer: TIDEVer = ivDXE;
{$ENDIF}
{$IFDEF VER16}
  IDEVer: TIDEVer = ivDXE2;
{$ENDIF}
{$IFDEF VER17}
  IDEVer: TIDEVer = ivDXE3;
{$ENDIF}
{$IFDEF VER18}
  IDEVer: TIDEVer = ivDXE4;
{$ENDIF}
{$IFDEF VER19}
  IDEVer: TIDEVer = ivDXE5;
{$ENDIF}
{$IFDEF VER20}
  IDEVer: TIDEVer = ivDXE6;
{$ENDIF}
{$IFDEF VER21}
  IDEVer: TIDEVer = ivDXE7;
{$ENDIF}
{$IFDEF VER22}
  IDEVer: TIDEVer = ivDXE8;
{$ENDIF}
{$IFDEF CB5}
  IDEVer: TIDEVer = ivCB5;
{$ENDIF}
{$IFDEF CB6}
  IDEVer: TIDEVer = ivCB6;
{$ENDIF}
{$IFDEF FPC}
  IDEVer: TIDEVer = ivLazarus;
{$ENDIF}

