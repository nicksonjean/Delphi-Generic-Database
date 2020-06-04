//Classes
http://read.pudn.com/downloads702/doc/fileformat/2822011/SMPLELJ/FireMonkeyMobile/ListView/MultiDetailAppearanceU.pas__.htm
https://blog.hjf.pe.kr/323
https://resources.oreilly.com/examples/9781785287428/blob/master/Delphi_Cookbook/Chapter%207/CODE/RECIPE06/DelphiCookbookListViewAppearance/DelphiCookbookListViewAppearanceU.pas
//
https://stackoverflow.com/questions/37076388/add-tswitch-to-every-tlistview-item
https://en.delphipraxis.net/topic/1731-tlistview-multi-selection/

//Métodos de Alimentação
https://issue.life/questions/44899479
http://www.delphiturkiye.com/forum/viewtopic.php?t=35054
http://fire-monkey.ru/topic/2533-%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0-%D1%81-listview/

//Até Agora Não Funcionou
https://stackoverflow.com/questions/38305807/load-database-field-of-all-records-into-listview-item-detail-object
https://android.developreference.com/article/15955168/Load+database+field+of+all+records+into+ListView+Item+Detail+Object


procedure TSQLConnectionTester.ComboBoxSQLiteChange(Sender: TObject);
//var
//  Idx: Integer;
begin
//  Idx := TComboBox(Sender).ItemIndex;
//  Showmessage(TComboBox(Sender).Items[Idx]);
//  Showmessage(TValueObject(TComboBox(Sender).Items.Objects[Idx]).Value.AsString);
end;

procedure TSQLConnectionTester.EditSQLiteChangeTracking(Sender: TObject);
//var
//  Idx: Integer;
begin
//  Idx := TEdit(Sender).ItemIndex;
//  Showmessage(TEdit(Sender).Items[Idx]);
//  Showmessage(TValueObject(TEdit(Sender).Items.Objects[Idx]).Value.AsString);
end;

procedure TSQLConnectionTester.ComboEditSQLiteChangeTracking(Sender: TObject);
//var
//  Idx: Integer;
begin
//  Idx := TComboEdit(Sender).ItemIndex;
//  Showmessage(TComboEdit(Sender).Items[Idx]);
//  Showmessage(TValueObject(TComboEdit(Sender).Items.Objects[Idx]).Value.AsString);
end;


**************


{
 Procedure ObjectOlustur( AItem:TListViewItem; LItem: TListItemText; strRefKod, strText:String; iOffsetX, iOffsetY, iWidth,iHeight, iFontSize:Integer; iFontColor: LongInt );
  begin
    LItem                := TListItemText.Create(AItem);
    LItem.Name           := strRefKod;
    LItem.Font.Size      := iFontSize;
    LItem.TextColor      := iFontColor;
    LItem.Align          := TListItemAlign.Leading; // En Sol
    LItem.VertAlign      := TListItemAlign.Leading; // En Üst
    LItem.PlaceOffset.X  := iOffsetX;
    LItem.PlaceOffset.Y  := iOffsetY;
    LItem.TextAlign      := TTextAlign.taLeading;
    LItem.Trimming       := TTextTrimming.ttCharacter;
    LItem.IsDetailText   := False;
    LItem.Width          := iWidth;
    LItem.Height         := iHeight;
    LItem.Text           := strText;
  end;

//****

procedure RSS_Parse( ListView:TListView; IdHttp:TIdHttp; Progress:TProgressBar );
  Procedure ObjectOlustur( AItem:TListViewItem; LItem: TListItemText; strRefKod, strText:String; iOffsetX, iOffsetY, iWidth,iHeight, iFontSize:Integer; iFontColor: LongInt );
  begin
    LItem                := TListItemText.Create(AItem);
    LItem.Name           := strRefKod;
    LItem.Font.Size      := iFontSize;
    LItem.TextColor      := iFontColor;
    LItem.Align          := TListItemAlign.Leading; // En Sol
    LItem.VertAlign      := TListItemAlign.Leading; // En Üst
    LItem.PlaceOffset.X  := iOffsetX;
    LItem.PlaceOffset.Y  := iOffsetY;
    LItem.TextAlign      := TTextAlign.taLeading;
    LItem.Trimming       := TTextTrimming.ttCharacter;
    LItem.IsDetailText   := True;
    LItem.Width          := iWidth;
    LItem.Height         := iHeight;
    LItem.Text           := strText;
  end;

Const
  URL = 'http://www.turkanime.tv/rss.xml';
Type tBilgi = Record
  strTitle,
  strLink,
  strDescription,
  strPubDate,
  strAuthor,
  strGuid : String;
end;
Var
  strIcerik,
  strAra,
  strGecici,
  strBlok : String;
  Bilgi   : tBilgi;
  AItem   : TListViewItem;
  LImage  : TListItemImage;
  LData1,  LData2,  LData3,  LData4,
  LLabel1, LLabel2, LLabel3  : TListItemText;
  MS : TMemoryStream;
  iSayac : Integer;
begin
  ListView.ClearItems;
  strIcerik := IdHttp.Get( URL );

  // Sadece Kaç Başık var onu sayıcaz. Progressbar için ön çalışma...
  strGecici := strIcerik;
  iSayac    := 0;
  strAra := '<item>';
  while Pos(strAra, strGecici) > 0 do
  begin
    System.Delete( strGecici, 1, Pos(strAra, strGecici) + Length(strAra)-1 );
    inc(iSayac);
  end;
  if Progress <> nil then
  begin
    Progress.Min := 0;
    Progress.Max := iSayac;
    Progress.Visible := True;
  end;
  iSayac := 0;
  while Pos('<item>', strIcerik) > 0 do
  begin
    Application.ProcessMessages;
    inc(iSayac);
    if Progress <> nil then Progress.Value := iSayac;

    strAra := '<item>';
    System.Delete( strIcerik, 1, Pos(strAra, strIcerik) + Length(strAra)-1 );
    strAra := '</item>';

    // strBlok içerisinde bir başlık ve bilgileri olacaktır...
    strBlok := Copy(strIcerik, 1, Pos( strAra, strIcerik ) + Length(strAra)-1 );

    FillChar( Bilgi, sizeOf(Bilgi), 0 );
    strAra := '<title>';
    if Pos( strAra, strBlok ) > 0 then
    begin
      strGecici := strBlok;
      System.Delete(strGecici, 1, Pos(strAra, strGecici) + Length(strAra)-1 );
      Bilgi.strTitle := Trim(Copy(strGecici, 1, Pos('<', strGecici)-1 ));
    end;

    strAra := '<link>';
    if Pos( strAra, strBlok ) > 0 then
    begin
      strGecici := strBlok;
      System.Delete(strGecici, 1, Pos(strAra, strGecici) + Length(strAra)-1 );
      Bilgi.strLink := Trim(Copy(strGecici, 1, Pos('<', strGecici)-1 ));
    end;

    strAra := '<description>';
    if Pos( strAra, strBlok ) > 0 then
    begin
      strGecici := strBlok;
      System.Delete(strGecici, 1, Pos(strAra, strGecici) + Length(strAra)-1 );
      strAra := 'src="';
      System.Delete(strGecici, 1, Pos(strAra, strGecici) + Length(strAra)-1 );
      Bilgi.strDescription := Trim(Copy(strGecici, 1, Pos('"', strGecici)-1 ));
    end;

    strAra := '<pubDate>';
    if Pos( strAra, strBlok ) > 0 then
    begin
      strGecici := strBlok;
      System.Delete(strGecici, 1, Pos(strAra, strGecici) + Length(strAra)-1 );
      Bilgi.strPubDate := Trim(Copy(strGecici, 1, Pos('<', strGecici)-1 ));
    end;

    strAra := '<author>';
    if Pos( strAra, strBlok ) > 0 then
    begin
      strGecici := strBlok;
      System.Delete(strGecici, 1, Pos(strAra, strGecici) + Length(strAra)-1 );
      Bilgi.strAuthor := Trim(Copy(strGecici, 1, Pos('<', strGecici)-1 ));
    end;

    strAra := '<guid>';
    if Pos( strAra, strBlok ) > 0 then
    begin
      strGecici := strBlok;
      System.Delete(strGecici, 1, Pos(strAra, strGecici) + Length(strAra)-1 );
      Bilgi.strGuid := Trim(Copy(strGecici, 1, Pos('<', strGecici)-1 ));
    end;

    if Bilgi.strTitle <> '' then
    begin
      AItem := ListView.Items.Add;
      AItem.Height := 132;
      AItem.Text   := '';

      LImage                  := TListItemImage.Create(AItem);
      LImage.Name             := 'Resim';
      LImage.Align            := TListItemAlign.Trailing; // En Sağ
      LImage.VertAlign        := TListItemAlign.Center;   // Orta
      LImage.PlaceOffset.Y    := 2;
      LImage.PlaceOffset.X    := 0;
      LImage.Width            := 90;
      LImage.Height           := 128;
      LImage.OwnsBitmap       := True;
      LImage.Bitmap           := TBitmap.Create(0, 0);
      MS := TMemoryStream.Create;
        IdHttp.Get(Bilgi.strDescription, MS);
        MS.Seek(0,soFromBeginning);
        LImage.Bitmap.LoadFromStream(MS);
      MS.Free;

      // Başlıklar
      // -----------------------------------------------------------------------------
        ObjectOlustur( AItem, LLabel1, 'Bas1', 'Title:', 4, 20, 500, 20, 8, TAlphaColorRec.Maroon );
        ObjectOlustur( AItem, LLabel2, 'Bas2', 'PubDt:', 4, 40, 500, 20, 8, TAlphaColorRec.Black );
        ObjectOlustur( AItem, LLabel3, 'Bas3', 'Auth.:', 4, 60, 500, 20, 8, TAlphaColorRec.Black );
      // Veri Alanları
      // -----------------------------------------------------------------------------
        ObjectOlustur( AItem, LData1, 'Data1', Bilgi.strTitle,       54,  20, 500, 20, 8, TAlphaColorRec.Maroon );
        ObjectOlustur( AItem, LData2, 'Data2', Bilgi.strPubDate,     54,  40, 500, 20, 8, TAlphaColorRec.Black );
        ObjectOlustur( AItem, LData3, 'Data3', Bilgi.strAuthor,      54,  60, 500, 20, 8, TAlphaColorRec.Black );
        ObjectOlustur( AItem, LData4, 'Data4', Bilgi.strLink,        04, 100, 500, 20, 8, TAlphaColorRec.Black );
     end;
  end; // While
  if Progress <> Nil then Progress.Visible := False;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  AniIndicator1.Visible := True;
  RSS_Parse( ListView1, IdHTTP1, ProgressBar1 );
  AniIndicator1.Visible := False;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  IdHttp1.Disconnect;
  // Bizim Close()'un Android karşılığı...
  // USES FMX.Platform.Android
  // MainActivity.Finish();
  FMX.Platform.Android.MainActivity.finish();
end;

procedure TForm1.ListView1ItemClick(const Sender: TObject;
  const AItem: TListViewItem);
var
  Intent : JIntent; // Androidapi.JNI.GraphicsContentViewText
  strURL : String;
begin
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_VIEW);
  strURL := (AItem.Objects.FindObject('Data4') as TListItemText).Text;
  Intent.setData(StrToJURI( strURL ));
  SharedActivity.startActivity(Intent);
end;

//*******

procedure TMain.ChannelListItemClick(const Sender: TObject;
  const AItem: TListViewItem);
var
  SName, SLink: string;
begin
  MenuList.Visible := False;
  if App.Network = True then
  begin
    if ChannelList.ItemIndex <> - 1 then
    begin
      App.ShowToast(IntToStr(Main.ChannelList.ItemIndex + 1) + '. ' + (AItem.Objects.FindObject('name') as TListItemText).Text, False);
      SName := (AItem.Objects.FindObject('name') as TListItemText).Text;
      SLink := (AItem.Objects.FindObject('url') as TListItemText).Text;
      App.Play(SName, SLink);
    end;
  end else
  begin
    App.ShowToast('İnternet bağlantsı yoxdur!', False);
  end;
end;

procedure TApp.ObjectC(AItem: TListViewItem; LItem: TListItemText; strRefKod,
  strText: string; iOffsetX, iOffsetY: Integer);
begin
  LItem := TListItemText.Create(AItem);
  LItem.Name := strRefKod;
  LItem.PlaceOffset.X := iOffsetX;
  LItem.PlaceOffset.Y := iOffsetY;
  LItem.Text := strText;
  if strRefKod = 'url' then
    LItem.Visible := False;
end;

procedure TApp.AddList(ListView: TListView; Query: TFDQuery);
var
  LItem: TListViewItem;
  LImage: TListItemImage;
  LI1, LI2: TListItemText;
  I: Integer;
  MS: TMemoryStream;
begin
  ListView.Items.Clear;
  ListView.BeginUpdate;
  with Query do
  begin
    SQL.Clear;
    SQL.Text := 'Select * From channels';
    Open();
  end;
  Query.First;
  for I := 0 to Query.RecordCount - 1 do
  begin
    LItem := ListView.Items.Add;
    LItem.Height := 62;
    LItem.Text := '';
    LImage := TListItemImage.Create(LItem);
    LImage.Align := TListItemAlign.Leading;
    LImage.VertAlign := TListItemAlign.Center;
    LImage.Width := 48;
    LImage.Height := 48;
    LImage.OwnsBitmap := True;
    LImage.Bitmap := TBitmap.Create(0, 0);
    MS := TMemoryStream.Create;
    MS.LoadFromFile(TPath.Combine(TPath.GetDocumentsPath, 'tv.png'));
    MS.Seek(0, soFromBeginning);
    LImage.Bitmap.LoadFromStream(MS);
    MS.Free;
    ObjectC(LItem, LI1, 'name', Query.FieldByName('name').Text, 54,  20);
    ObjectC(LItem, LI2, 'url', Query.FieldByName('url').Text, 54,  20);
    Query.Next;
  end;
  ListView.EndUpdate;
  Query.Active := False;
end;

}