unit BootstrapStyle.Colors;

{
  Bootstrap 5.3 theme colors (solid buttons + hover approximations).
}

interface

uses
  System.UITypes;

const
  BS_PRIMARY         = $FF0D6EFD;
  BS_PRIMARY_HOVER   = $FF0B5ED7;
  BS_SECONDARY       = $FF6C757D;
  BS_SECONDARY_HOVER = $FF5C636A;
  BS_SUCCESS         = $FF198754;
  BS_SUCCESS_HOVER   = $FF157347;
  BS_DANGER          = $FFDC3545;
  BS_DANGER_HOVER    = $FFBB2D3B;
  BS_WARNING         = $FFFFC107;
  BS_WARNING_HOVER   = $FFFFCA2C;
  BS_INFO            = $FF0DCAF0;
  BS_INFO_HOVER      = $FF31D2F2;
  BS_LIGHT           = $FFF8F9FA;
  BS_LIGHT_HOVER     = $FFD3D4D5;
  BS_DARK            = $FF212529;
  BS_DARK_HOVER      = $FF1C1F23;
  BS_LINK            = $FF0D6EFD;
  BS_LINK_HOVER      = $FF0A58CA;

  BS_TEXT_ON_DARK    = $FFFFFFFF;
  BS_TEXT_ON_LIGHT   = $FF212529;

  { Sidebar nav-pills (dark theme) }
  BS_MENU_ACTIVE_BG     = BS_PRIMARY;
  BS_MENU_ACTIVE_ICON   = BS_TEXT_ON_DARK;
  BS_MENU_ACTIVE_TEXT   = BS_TEXT_ON_DARK;
  BS_MENU_INACTIVE_ICON = BS_TEXT_ON_DARK;
  BS_MENU_INACTIVE_TEXT = BS_TEXT_ON_DARK;

implementation

end.
