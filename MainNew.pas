unit MainNew;

{ $ define debug}

// Komment
// komment 2
interface

uses
  Settings,
  AdvChart,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  FireDAC.UI.Intf, FireDAC.VCLUI.Wait, Vcl.ExtCtrls, Vcl.Menus, AdvMenus,
  FireDAC.Stan.Intf, FireDAC.Comp.UI, AdvChartView, AdvChartViewGDIP,
  AdvOfficeStatusBar, AdvOfficePager, System.Classes,
  Vcl.Graphics;

type
  TMainform = class(TForm)
    AdvOfficePager1: TAdvOfficePager;
    AdvOfficePager11: TAdvOfficePage;

    AdvOfficeStatusBar1: TAdvOfficeStatusBar;
    AdvOfficePager12: TAdvOfficePage;
    AdvOfficePager13: TAdvOfficePage;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    AdvPopupMenu1: TAdvPopupMenu;
    Vljdata1: TMenuItem;
    Sparasombild1: TMenuItem;
    Visatableert1: TMenuItem;
    Timer1: TTimer;
    DebugStandarddatum1: TMenuItem;
    AdvGDIPChartView1: TAdvGDIPChartView;
    ChartDay: TAdvGDIPChartView;
    N1: TMenuItem;
    Instllningar1: TMenuItem;
    ChartDVT: TAdvGDIPChartView;
    procedure Timer1Timer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Vljdata1Click(Sender: TObject);
    procedure Visatableert1Click(Sender: TObject);
    procedure DebugStandarddatum1Click(Sender: TObject);
    procedure Instllningar1Click(Sender: TObject);
  private
    procedure UpdateDay;
    procedure UpdateDVT;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Mainform: TMainform;

implementation

{$R *.dfm}

uses DatumSelect, Data;

procedure TMainform.DebugStandarddatum1Click(Sender: TObject);
begin
  DataForm.Datum := StrTodate('2014-10-07');
  Timer1Timer(Sender)
end;

procedure TMainform.FormActivate(Sender: TObject);
begin
  Timer1Timer(Sender);
  Caption := DateToStr(DataForm.Datum);
  {$ifdef debug}
  //DataForm.Datum := StrTodate('2014-10-07');
  //Timer1Timer(Sender)
  {$endif}
end;

procedure TMainform.FormResize(Sender: TObject);
begin
  ChartDay.Panes[0].Legend.left := ChartDay.left + ChartDay.Width - 300;
  ChartDay.Panes[0].Legend.top := ChartDay.top + 50;
end;

procedure TMainform.Instllningar1Click(Sender: TObject);
begin
  // Inst�llningar f�r filter etc
  FSettings.ShowModal;
end;

procedure TMainform.Visatableert1Click(Sender: TObject);
begin
  DataForm.Show
end;

procedure TMainform.UpdateDay;
var
  i: Integer;
begin

  Caption := DateToStr(DataForm.Datum);
  ChartDay.beginupdate;
  ChartDay.ClearPaneSeries;
  for i := 0 to 23 do
  begin
    ChartDay.Panes[0].Series[2].AddSingleXYPoint(i,
      DataForm.DayGrafArray[i].SignSum);
    ChartDay.Panes[0].Series[1].AddSingleXYPoint(i,
      DataForm.DayGrafArray[i].Remsum);
    ChartDay.Panes[0].Series[0].AddSingleXYPoint(i,
      DataForm.DayGrafArray[i].UsSum);
  end;
  ChartDay.Panes[0].Series[1].LineColor := RGB(255, 50, 50);
  ChartDay.Panes[0].Series[1].LineWidth := 3;
  ChartDay.Panes[0].Series[1].legendtext := 'Remisser / timme';
  ChartDay.Panes[0].Series[1].ChartType := ctBar;
  ChartDay.Panes[0].Series[1].Color := clYellow;
  ChartDay.Panes[0].Series[2].LineColor := RGB(120, 25, 27);
  ChartDay.Panes[0].Series[2].LineWidth := 3;
  ChartDay.Panes[0].Series[2].legendtext := 'Signerade unders�kningar / timme';
  ChartDay.Panes[0].Series[2].ChartType := ctLine;
  ChartDay.Panes[0].Series[2].Color := RGB(255, 200, 120);
  ChartDay.Panes[0].Series[0].ChartType := ctBar;
  ChartDay.Panes[0].Series[0].legendtext := 'Utf�rda unders�kningar / timme';
  ChartDay.Panes[0].Series[0].Color := clGreen;
  ChartDay.Panes[0].Range.RangeTo := 19;
  ChartDay.Panes[0].Range.Rangefrom := 7;

  for i := 0 to 2 do
  begin
    ChartDay.Panes[0].Series[i].Minimum := -1;
    ChartDay.Panes[0].Series[i].Maximum := 20;
  end;
  ChartDay.Endupdate;
end;

procedure TMainform.UpdateDVT;
var
  R:TRect;
  TStart,TEnd: Real;
  i: Integer;
  C: TColor;

begin
  ChartDVT.beginupdate;
  ChartDVT.ClearPaneSeries;

  ChartDVT.Panes[0].Series[0].Color := clBlue;
  ChartDVT.Panes[0].Series[0].ChartType := ctBar;
  ChartDVT.Panes[0].Series[0].legendtext := 'Tid fr�n remiss till svar DVT';
  ChartDVT.Panes[0].Series[0].Color := clBlue;

  R.Left:=0; //ChartDVT.Left;
  R.Right:=ChartDVT.Width; // -R.Left;

  for i := 0 to Length(DataForm.DVTGrafArray) do
  begin

    // if Dataform.DVTGrafArray[i].RegTid > 0 then
    // begin
    if DataForm.DVTGrafArray[i].LedDagar > 0 then
      C := clRed
    else
      C := clGreen;

    ChartDVT.Panes[0].Series[0].AddSingleXYPoint
      (DataForm.DVTGrafArray[i].RegTid, DataForm.DVTGrafArray[i].LedTimmar +
      DataForm.DVTGrafArray[i].LedMinuter / 60, C);

    // end;
  end;
  ChartDVT.Endupdate
end;

procedure TMainform.Vljdata1Click(Sender: TObject);
begin

  Datumform.TempDatum := DataForm.Datum;
  Datumform.ShowModal;
  DataForm.Datum := Datumform.TempDatum;

  DataForm.Update;
  UpdateDay;
  UpdateDVT
end;

procedure TMainform.Timer1Timer(Sender: TObject);
begin
  DataForm.Update;
  UpdateDay;
  UpdateDVT
end;

end.
