unit BootstrapStyle.Core;

{
  Bootstrap 5 shared types and internal name constants.

  This unit is the single source of truth for:
    • TBootstrapVariant  — the nine Bootstrap 5 colour variants
    • TBootstrapButtonPaint — paint descriptor used when building button visuals
    • Internal child-object name constants (BS_BG_NAME, etc.)
    • BS_HOVER_TAG_BASE — sentinel used by the hover-hook to identify variant from Tag

  Used by:
    BootstrapStyle.Buttons  — button styling implementation
    BootstrapStyle           — public façade (re-exports types for caller convenience)
}

interface

uses
  System.UITypes;

const
  { Offset stored in TControl.Tag to identify the Bootstrap variant at hover time.
    Value is arbitrary but must not collide with application-defined tags. }
  BS_HOVER_TAG_BASE = 910000000;

  { Names for child objects injected into styled controls.
    Double-underscore prefix guarantees no collision with designer-placed names. }
  BS_BG_NAME    = '__BSBg__';
  BS_INNER_NAME = '__BSInner__';
  BS_ICON_NAME  = '__BSIcon__';
  BS_TEXT_NAME  = '__BSText__';

type
  { The nine Bootstrap 5 contextual variants (matches Bootstrap 5.3 docs). }
  TBootstrapVariant = (
    bsPrimary,
    bsSecondary,
    bsSuccess,
    bsDanger,
    bsWarning,
    bsInfo,
    bsLight,
    bsDark,
    bsLink);

  { Resolved paint data for one variant: normal colour, hover colour, text colour,
    and whether the button has a solid fill (bsLink is the only transparent one). }
  TBootstrapButtonPaint = record
    Normal, Hover: TAlphaColor;
    TextColor: TAlphaColor;
    Solid: Boolean;
  end;

implementation

end.
