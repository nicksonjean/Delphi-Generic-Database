{$IFNDEF CLR}
unit CRDbxDesign;
{$ENDIF}

{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}
{$WARN UNIT_PLATFORM OFF}
{$WARN UNIT_DEPRECATED OFF}

interface

uses
{$IFDEF CLR}
  Borland.Vcl.Design.DesignIntf, Borland.Vcl.Design.DesignEditors,
  Borland.Vcl.Design.DbxCtrlsReg, Classes, SqlExpr,
{$ELSE}
  DesignIntf, DesignEditors, Classes, SqlReg, SqlExpr,
{$ENDIF}
  TypInfo;

// TCRSQLConnection should not contain addition attributes (for set ClassType)

type
  TCRSQLConnectionEditor = class (TSQLConnectionEditor)
  protected
    procedure DoConvert;
  public
    function GetVerbCount: integer; override;
    function GetVerb(Index: integer): string; override;
    procedure ExecuteVerb(Index: integer); override;
  end;

procedure Register;

implementation

uses
  CRSQLConnection;

{ TCRSQLConnectionEditor }

procedure TCRSQLConnectionEditor.ExecuteVerb(Index: integer);
begin
  case Index - inherited GetVerbCount of
    0: DoConvert;
  else
    inherited ExecuteVerb(Index);
  end
end;

function TCRSQLConnectionEditor.GetVerb(Index: integer): string;
begin
  case Index - inherited GetVerbCount  of
    0: if Component.ClassType = TSQLConnection then
         result := 'Convert to TCRSQLConnection'
       else
         result := 'Convert to TSQLConnection';
  else
    result := inherited GetVerb(Index);
  end
end;

procedure ConvertToClass(Designer:IDesigner; Component: TComponent; NewClass: TComponentClass);
type
  TPropData = record
    Component: TComponent;
    PropInfo: PPropInfo;
  end;
var
  AName: string;
  NewComponent: TComponent;
  DesignInfo: Integer;
  Instance: TComponent;

  FreeNotifies: TList;
  i, j, PropCount: integer;
{$IFDEF CLR}
  PropList: TPropList;
{$ELSE}
  PropList: PPropList;
{$ENDIF}
  Refs: array of TPropData;
  l: integer;

  Root: TComponent;

  procedure AssignComponent(NewComponent: TComponent; Component: TComponent);
  var
    i, PropCount: integer;
  {$IFDEF CLR}
    PropList: TPropList;
    PropInfo: TPropInfo;
  {$ELSE}
    PropList: PPropList;
    PropInfo: PPropInfo;
  {$ENDIF}
    Obj, NewObj: TPersistent;

  begin
  {$IFDEF CLR}
    PropList := GetPropList(NewClass.ClassInfo, tkAny, False);
    PropCount := Length(PropList);
  {$ELSE}
    PropCount := GetPropList(NewClass.ClassInfo, tkAny, nil, False);
    GetMem(PropList, PropCount * sizeof(PropList[0]));
    try
      GetPropList(NewClass.ClassInfo, tkAny, PropList, False);
  {$ENDIF}
      for i := 0 to PropCount - 1 do begin
        PropInfo := GetPropInfo(Component, PropList[i].Name);
        if (PropInfo <> nil) // published property
          and (PropList[i].Name <> 'Name')
          and (IsStoredProp(Component, PropInfo)) then
          case PropList[i].PropType{$IFNDEF CLR}^{$ENDIF}.Kind of
            tkClass:
            begin
            {$IFDEF CLR}
              Obj := GetObjectProp(Component, PropInfo) as TPersistent;
            {$ELSE}
              Obj := TPersistent(integer(GetPropValue(Component, PropList[i].Name)));
            {$ENDIF}

              if Obj <> nil then begin
                Assert(Obj is TPersistent);
              {$IFDEF CLR}
                NewObj := GetObjectProp(NewComponent, PropList[i].Name) as TPersistent;
              {$ELSE}
                NewObj := TPersistent(integer(GetPropValue(NewComponent, PropList[i].Name)));
              {$ENDIF}
                if NewObj = nil then begin
                {$IFDEF CLR}
                  NewObj := Obj;
                {$ENDIF}
                  SetObjectProp(Component, PropInfo, nil);
                end
                else
                begin
                  Assert(NewObj is TPersistent);
                  NewObj.Assign(Obj);
                end;
              {$IFDEF CLR}
                SetObjectProp(NewComponent, PropInfo, NewObj);
              {$ENDIF}
              end;
            end;
            tkMethod:
              SetMethodProp(NewComponent, PropList[i], GetMethodProp(Component, PropList[i]));
            else
              SetPropValue(NewComponent, PropList[i].Name, GetPropValue(Component, PropList[i].Name));
          end;
      end;
  {$IFNDEF CLR}
    finally
      FreeMem(PropList);
    end;
  {$ENDIF}
  end;
begin
  DesignInfo := Component.DesignInfo;
  NewComponent := Designer.CreateComponent(NewClass, Component.Owner,
    Word(DesignInfo {$IFDEF CLR}shr 16{$ENDIF}), Word(DesignInfo  {$IFNDEF CLR}shr 16{$ENDIF}), 28, 28);
  AName := Component.Name;
  Component.Name := 'CRTemp_' + AName;
  FreeNotifies := TList.Create;
  try
    Root := Designer.Root;
    for i := 0 to Root.ComponentCount - 1 do begin
      FreeNotifies.Add(Root.Components[i]);
    end;
    for i := 0 to FreeNotifies.Count - 1 do begin
      Instance := TComponent(FreeNotifies[i]);
    {$IFDEF CLR}
      PropList := GetPropList(Instance.ClassInfo, [tkClass]{$IFNDEF CLR}, nil, False{$ENDIF});
      PropCount := Length(PropList);
      if PropCount > 0 then begin
    {$ELSE}
      PropCount := GetPropList(Instance.ClassInfo, [tkClass]{$IFNDEF CLR}, nil, False{$ENDIF});
      if PropCount > 0 then begin
        GetMem(PropList, PropCount * SizeOf(PropList[0]));
        try
          GetPropList(Instance.ClassInfo, [tkClass]{$IFNDEF CLR}, PropList, False{$ENDIF});
    {$ENDIF}
          for j := 0 to PropCount - 1 do begin
            if (PropList[j].PropType <> nil) and
            ({$IFDEF CLR}KindOf(PropList[j].PropType){$ELSE}PropList[j].PropType^.Kind{$ENDIF}= tkClass)
              and (TComponent(GetObjectProp(Instance, PropList[j])) = Component)
            then begin
              l := Length(Refs);
              SetLength(Refs, l + 1);
              Refs[l].Component := Instance;
              Refs[l].PropInfo := PropList[j];
            end;
          end;
    {$IFNDEF CLR}
        finally
          FreeMem(PropList);
        end;
      end;
    {$ELSE}
      end;
    {$ENDIF}
    end;
  finally
    FreeNotifies.Free;
  end;

  AssignComponent(NewComponent, Component);

  for i := 0 to Length(Refs) - 1 do begin
    SetObjectProp(Refs[i].Component, Refs[i].PropInfo, NewComponent);
  end;
  Component.Free;
  NewComponent.Name := AName;
  Designer.Modified;
end;

function TCRSQLConnectionEditor.GetVerbCount: integer;
begin
  result := inherited GetVerbCount + 1;
end;

procedure TCRSQLConnectionEditor.DoConvert;
var
  Name: string;
begin
  // Set ClassType to object instance
  if Component.ClassType = TSQLConnection then
    ConvertToClass(Self.Designer, Component, TCRSQLConnection)
  else
    ConvertToClass(Self.Designer, Component, TSQLConnection);

  Designer.Modified;
  Designer.ShowMethod(Name);
end;

procedure Register;
begin
  RegisterComponents('dbExpress', [TCRSQLConnection]);
  RegisterComponentEditor(TSQLConnection, TCRSQLConnectionEditor);
end;

end.
