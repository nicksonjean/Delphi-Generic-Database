unit FMX.Edit.Suggest.Messages;

{
  Constantes de mensagem e tipos partilhados entre TStyledSuggestEdit (FMX.Edit.Extension)
  e TEditHelper (FMX.Edit.Helper).
}

interface

uses
  FMX.Edit;

const
  PM_DROP_DOWN = PM_EDIT_USER + 10;
  PM_PRESSENTER = PM_EDIT_USER + 11;
  PM_SET_ITEMINDEX = PM_EDIT_USER + 12;
  PM_GET_ITEMINDEX = PM_EDIT_USER + 13;
  PM_GET_SELECTEDITEM = PM_EDIT_USER + 14;
  PM_SET_ITEMCHANGE_EVENT = PM_EDIT_USER + 15;
  PM_GET_ITEMS = PM_EDIT_USER + 16;
  PM_REBUILD_SUGGESTIONS = PM_EDIT_USER + 17;
  PM_CLEAR_SUGGESTION_LISTBOX = PM_EDIT_USER + 18;
  PM_SET_EXTENSION = PM_EDIT_USER + 19;

  { TagString value written by the helper to opt a specific component into the extension.
    The presenter reads this flag before activating popup/button features. }
  EXT_TAG = 'DGD.Extension.Active';

type
  TSelectedItem = record
    Text: String;
    Data: TObject;
  end;

implementation

end.
