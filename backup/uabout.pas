unit uabout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons,Clipbrd;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    BitBtn1: TBitBtn;
    btnAceptar: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    procedure BitBtn1Click(Sender: TObject);
    procedure btnAceptarClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure StaticText1Click(Sender: TObject);
    procedure StaticText1MouseEnter(Sender: TObject);
    procedure StaticText1MouseLeave(Sender: TObject);
    procedure StaticText2Click(Sender: TObject);
    procedure StaticText2MouseEnter(Sender: TObject);
    procedure StaticText2MouseLeave(Sender: TObject);
  private

  public

  end;


implementation

uses lclintf;

{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.btnAceptarClick(Sender: TObject);
begin

end;

procedure TfrmAbout.BitBtn1Click(Sender: TObject);
begin
  Clipboard.asText := 'josduran@gmail.com';
end;

procedure TfrmAbout.Image1Click(Sender: TObject);
begin

end;

procedure TfrmAbout.StaticText1Click(Sender: TObject);
begin
   OpenURL('www.chasquicloud.com')
end;

procedure TfrmAbout.StaticText1MouseEnter(Sender: TObject);
begin
   StaticText1.Cursor := crHandPoint;
{cursor changes into handshape when it is on StaticText}
  StaticText1.Font.Color := clBlue;
{StaticText changes color into blue when cursor is on StaticText}
end;

procedure TfrmAbout.StaticText1MouseLeave(Sender: TObject);
begin
  StaticText1.Font.Color := clDefault;
{when cursor is not on StaticText then color of text changes into default color}
end;

procedure TfrmAbout.StaticText2Click(Sender: TObject);
begin
OpenURL('mailto:theo@test.com?subject=test&body=Hello World');
end;

procedure TfrmAbout.StaticText2MouseEnter(Sender: TObject);
begin
   StaticText2.Font.Color := clBlue;
end;

procedure TfrmAbout.StaticText2MouseLeave(Sender: TObject);
begin
  StaticText2.Font.Color := clDefault;
end;

end.

