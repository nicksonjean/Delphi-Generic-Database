﻿unit FMX.ComboBox.Helper;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.DateUtils,
  FMX.Forms,
  FMX.Pickers,
  FMX.ListBox,
  FMX.Types,
  FMX.Controls,
  FMX.StdCtrls,
  EventDriven;

//https://living-sun.com/pt/delphi/232199-how-can-i-make-a-searchbox-visible-when-i-open-the-list-of-a-combobox-in-delphi-delphi-combobox-firemonkey-search-box.html
//https://code5.cn/so/delphi/706730
//https://android.developreference.com/article/18385583/TSearchBox+in+front+of+TListBoxItem+in+Android+with+Delphi+XE8

//https://blog.dummzeuch.de/2019/06/22/setting-the-drop-down-width-of-a-combobox-in-delphi/
//https://android.developreference.com/article/16137058/AutoComplete+functionality+for+FireMonkey+'s+TComboEdit
//http://www.devsuperpage.com/search/Articles.aspx?G=2&ArtID=22743
//http://codeverge.com/embarcadero.delphi.firemonkey/combobox-auto-complete/1059515
//http://www.planetadelphi.com.br/dica/5104/auto-preencher-combo-ao-digitar
//https://www.devmedia.com.br/forum/autocomplete-combobox-em-firemonkey-delphi/598816

//http://yaroslavbrovin.ru/new-approach-of-development-of-firemonkey-control-control-model-presentation-part-2-tedit-with-autocomplete-en/
//https://www.developpez.net/forums/d1701716/environnements-developpement/delphi/composants-fmx/fonctionnement-tcomboedit/
//https://jquery.develop-bugs.com/article/15398626/How+can+I+make+a+SearchBox+visible+when+I+open+the+list+of+a+ComboBox+in+Delphi
//https://www.developpez.net/forums/d1942684/environnements-developpement/delphi/composants-fmx/combobox-auto-completion-chose/

type
  TComboBoxHack = class(FMX.ListBox.TComboBox)
  private
    class var LastTimeKeydown:TDatetime;
    class var Keys:string;
  protected
    class procedure KeyDown(Sender: TObject; var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState); reintroduce;
  end;

type
  TComboBoxHelper = class helper for TComboBox
  public
    procedure AutoComplete;
    //property AutoTranslate: Boolean read FAutoTranslate write FAutoTranslate;
  end;

implementation

uses
  FMX.ListBox.Helper;

{ TComboBoxHelper }

procedure TComboBoxHelper.AutoComplete;
begin
  Self.OnKeyDown := DelegateKeyEvent(
    Self,
    procedure(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState)
    begin
      TComboBoxHack.KeyDown(Sender, Key, KeyChar, Shift);
    end
  );
end;

//https://android.developreference.com/article/16137058/AutoComplete+functionality+for+FireMonkey+'s+TComboEdit
//https://stackoverrun.com/ru/q/10367953
//https://stackoverflow.com/questions/37611345/autocomplete-functionality-for-firemonkey-s-tcomboedit
//https://xbuba.com/questions/37611345
//https://stackoverrun.com/ru/q/9303004
//https://code5.cn/so/delphi/706730

//https://stackoverflow.com/questions/7696075/need-a-combobox-with-filtering
//https://stackoverflow.com/questions/9466547/how-to-make-a-combo-box-with-fulltext-search-autocomplete-support
//https://jquery.develop-bugs.com/article/15398626/How+can+I+make+a+SearchBox+visible+when+I+open+the+list+of+a+ComboBox+in+Delphi

{ TComboboxHack }

class procedure TComboBoxHack.KeyDown(Sender: TObject; var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState);
var
  I: Integer;
begin
  if Key = vkReturn then
    Exit;
  if (KeyChar in [Chr(48)..Chr(57)]) or (KeyChar in [Chr(65)..Chr(90)]) or (KeyChar in [Chr(97)..Chr(122)]) then
  begin
    if MilliSecondsBetween(LastTimeKeydown, Now) < 500 then
      Keys := Keys + KeyChar
    else
      Keys := KeyChar;
    LastTimeKeydown := Now;
    for I := 0 to TComboBox(Sender).Count-1 do
    if UpperCase(Copy(TComboBox(Sender).Items[I], 0, Keys.Length)) = UpperCase(Keys) then
    begin
      TComboBox(Sender).ItemIndex := I;
      Break;
    end;
  end;
end;

end.
