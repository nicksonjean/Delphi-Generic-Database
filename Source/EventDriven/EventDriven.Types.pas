unit EventDriven.Types;

interface

uses
  System.Classes,
  System.Types,
  System.UITypes,
  System.Math.Vectors,
  FMX.Types,
  FMX.Controls;

type
  TMouseEvent = procedure(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single) of object;
  TMouseMoveEvent = procedure(Sender: TObject; Shift: TShiftState; X, Y: Single) of object;
  TMouseWheelEvent = procedure(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean) of object;
  TKeyEvent = FMX.Types.TKeyEvent;
  TProcessTickEvent = procedure(Sender: TObject; time, deltaTime: Single) of object;
  TVirtualKeyboardEvent = procedure(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect) of object;
  TTapEvent = procedure(Sender: TObject; const Point: TPointF) of object;
  TTouchEvent = procedure(Sender: TObject; const Touches: TTouches; const Action: TTouchAction) of object;

implementation

end.
