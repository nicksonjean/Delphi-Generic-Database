﻿unit FMX.Grid.Helper;

interface

uses
  FMX.Grid;

type
  TGridHelper = class helper for TGrid
  public
    procedure AutoSizeColumns(Column: Integer);
    procedure RemoveRows(RowIndex, RCount: Integer);
    procedure Clear;
  end;

implementation

//https://community.idera.com/developer-tools/programming-languages/f/delphi-language/68795/fmx-tgrid-row-heights-and-appearance-changes-after-1-000-000-rows
//https://stackoverflow.com/questions/43466884/fmx-tgrid-how-to-allow-user-to-move-columns-without-messing-up-the-data
//https://stackoverflow.com/questions/9260355/firemonkey-grid-control-styling-a-cell-based-on-a-value-via-the-ongetvalue-fu
//https://stackoverflow.com/questions/43466884/fmx-tgrid-how-to-allow-user-to-move-columns-without-messing-up-the-data?rq=1
//https://stackoverrun.com/fr/q/11950199
//https://www.manongdao.com/q-810506.html
//https://issue.life/questions/43418528
//https://issue.life/questions/43466884

{ TGridHelper }

procedure TGridHelper.AutoSizeColumns(Column: Integer);
begin

end;

procedure TGridHelper.Clear;
begin
  TGrid(Self).Clear;
end;

procedure TGridHelper.RemoveRows(RowIndex, RCount: Integer);
begin
  TGrid(Self).RemoveRows(RowIndex, RCount);
end;

end.