unit BootstrapStyle.Consts;

{
  Bootstrap 5 shared, non-color constants.

  Keep layout/metrics, internal resource names, and other "styling-only" values
  centralized here so all Bootstrap rendering logic stays consistent.

  Colors remain in BootstrapStyle.Colors.pas to keep the palette isolated from
  component metrics and internal identifiers.
}

interface

const
  { ── Typography ───────────────────────────────────────────────────────────── }

  { Base UI font used across Bootstrap-styled controls (non-icons). }
  BS_FONT_FAMILY_UI = 'Segoe UI';

  { Default font sizes kept here for cohesion.
    Note: buttons default to 15 in ApplyButton; form-controls default to 14. }
  BS_FONT_SIZE_FORMS_DEFAULT   = 14;
  BS_FONT_SIZE_BUTTONS_DEFAULT = 15;

  { ── Internal identifiers (injected child objects) ───────────────────────── }

  { Offset stored in TControl.Tag to identify the Bootstrap variant at hover time.
    Value is arbitrary but must not collide with application-defined tags. }
  BS_HOVER_TAG_BASE = 910000000;

  { Names for child objects injected into styled controls.
    Double-underscore prefix guarantees no collision with designer-placed names. }
  BS_BG_NAME    = '__BSBg__';
  BS_INNER_NAME = '__BSInner__';
  BS_ICON_NAME  = '__BSIcon__';
  BS_TEXT_NAME  = '__BSText__';

  { Forms overlay background rectangle tag-string. }
  BS_FORM_BG_NAME   = '__BSFormBg__';
  { Outer focus “ring” (Bootstrap box-shadow) drawn behind BS_FORM_BG_NAME. }
  BS_FORM_GLOW_NAME  = '__BSFormGlow__';
  { 1 px rounded border drawn ON TOP of the styled presentation so it is not
    covered by the platform’s opaque square chrome / content rect. }
  BS_FORM_STROKE_NAME = '__BSFormStroke__';

  { Spread of the focus ring outside the 1 px border (~Bootstrap 0.25 rem). }
  BS_FORM_FOCUS_RING_SPREAD = 4;

  { ── Buttons (BootstrapStyle.Buttons) ────────────────────────────────────── }
  BS_BTN_RADIUS          = 6;
  BS_BTN_HOVER_DURATION  = 0.15;
  BS_BTN_CONTENT_MARGINX = 12;
  BS_BTN_ICON_TEXT_EXTRA_WIDTH = 8;

  { ── Form controls (BootstrapStyle.Forms) ────────────────────────────────── }
  BS_FORM_RADIUS            = 6;
  BS_FORM_PROMPT_INSET_LEFT = 15;
  BS_FORM_PROMPT_REALIGN_DELAY_MS = 120;

  BS_FORM_BORDER_THICKNESS = 1;
  BS_FORM_BORDER_THICKNESS_FOCUS = 2;

  { Content layout padding (left/right = 12, top/bottom = 6) }
  BS_FORM_CONTENT_PAD_X = 12;
  BS_FORM_CONTENT_PAD_Y = 6;

  { External vertical scrollbar for TMemo.
    The FMX styled internal scrollbar is unreliable inside a presented TMemo;
    an external TScrollBar sibling is overlaid on the right edge instead. }
  BS_MEMO_EXTERN_SCROLL_W         = 10;  { pixel width of the external TScrollBar }
  BS_MEMO_SCROLL_INSET_RIGHT      =  1;  { gap: scrollbar right edge → memo border }
  BS_MEMO_SCROLL_INSET_VERT       =  1;  { gap: top/bottom of scrollbar → memo border }
  BS_MEMO_SCROLL_SMALL_CHANGE_DIV =  5;  { viewport fraction per arrow-key step }

  { ── FMX style resource identifiers (used by FindStyleResource) ──────────── }
  FMX_RES_BACKGROUND = 'background';
  FMX_RES_CONTENT    = 'content';
  FMX_RES_PROMPT     = 'prompt';
  FMX_RES_TEXT       = 'text';
  FMX_RES_BUTTON     = 'button';
  FMX_RES_ARROW      = 'arrow';
  FMX_RES_HEADER     = 'header';
  FMX_RES_BOX        = 'box';

  { FMX internal-name heuristics (child object names often include these). }
  FMX_NAME_CARET = 'caret';
  FMX_NAME_TEXT  = 'text';
  FMX_NAME_CURSOR    = 'cursor';
  FMX_NAME_SELECTION = 'selection';
  FMX_NAME_SEL       = 'sel';
  FMX_NAME_HIGHLIGHT = 'highlight';

implementation

end.

