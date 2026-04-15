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

  { Form controls — Bootstrap 5 form-control spec }
  BS_FORM_BG            = $FFFFFFFF;  { white background }
  BS_FORM_BG_DISABLED   = $FFE9ECEF;  { disabled / read-only background }
  BS_FORM_BORDER        = $FFDEE2E6;  { normal border (#dee2e6) }
  BS_FORM_BORDER_FOCUS  = $FF86B7FE;  { focus border (#86b7fe) }
  BS_FORM_TEXT          = $FF212529;  { body / input text (#212529) }
  BS_FORM_PLACEHOLDER   = $FF6C757D;  { placeholder / muted text (#6c757d) }

  { Table / Grid — Bootstrap 5 table spec }
  BS_TABLE_HEADER_BG    = $FFF8F9FA;  { thead background (table-light) }
  BS_TABLE_HEADER_TEXT  = $FF212529;  { thead text }
  BS_TABLE_BORDER       = $FFDEE2E6;  { table border (same as form-border) }
  BS_TABLE_ROW_HOVER    = $FFE2E6EA;  { row hover highlight }
  BS_TABLE_STRIPE       = $FFFAFAFA;  { alternating-row tint }

  { FMX styled-mode approximation of the Windows-default border colour.
    Used when reverting form controls to the FMX default appearance. }
  FMX_CTRL_BORDER       = $FFD4D4D4;

implementation

end.
