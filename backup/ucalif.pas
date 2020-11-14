unit ucalif;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls;

type

  { TfrmRating }

  TfrmRating = class(TForm)
    btnOK: TButton;
    BtnCancel: TButton;
    Edit1: TEdit;
    TrackBar1: TTrackBar;
    procedure TrackBar1Change(Sender: TObject);
  private



  public
    class function GetCalif( var ACalif: integer): boolean;
  end;



implementation

{$R *.lfm}

procedure TfrmRating.TrackBar1Change(Sender: TObject);
var
  apos: integer;
  aposeq: double;
  atext: string;
begin
  apos:= TrackBar1.Position;
  aposeq:= apos*.5
  atext:= FloatToStr(aposeq);
  edit1.Text:= atext ;
end;

class function TfrmRating.GetCalif( var ACalif: integer): boolean;
var
  AfrmRating: TFrmRating;
begin
  AfrmRating:= TFrmRating.create(nil);
  try
    result:= (AfrmRating.ShowModal=mrOK );
    acalif:=  afrmRating.TrackBar1.position;
  finally
    AfrmRating.free;
  end;

end;

end.

