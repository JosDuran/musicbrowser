unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, sqlite3conn, sqldb, sqldblib, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, Grids, DBGrids, FileUtil, process, IniFiles;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnLoadAlbums: TButton;
    btnRepetidos: TButton;
    BtnFiltrar: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    pnlButtons: TPanel;
    Panel3: TPanel;
    grdAlbums: TStringGrid;
    procedure BtnFiltrarClick(Sender: TObject);
    procedure btnRepetidosClick(Sender: TObject);
    procedure btnLoadAlbumsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure grdAlbumsClick(Sender: TObject);
    procedure grdAlbumsDblClick(Sender: TObject);
    procedure grdAlbumsHeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
    procedure grdAlbumsKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    falbums: TList;
    forder: boolean;
    fdeffolder: string;
    fexecutable: string;
    fcmd: string;
    procedure CreateLalbumsFromDir(ADir: string);
    procedure FillStringGrid;
    procedure ExcludeDiferents(ACriter: string);
    procedure Sortlist(ACritery: string; aOrder: integer); //0 ascendente 1 descendente

  public

  end;

var
  frmMain: TfrmMain;

implementation

uses
  UfolderHash, ureport, ucalif;


{$R *.lfm}

{ TfrmMain }
// muestra los albums cargados de la ruta que se especifica en el archivo configapp.ini
procedure TfrmMain.btnLoadAlbumsClick(Sender: TObject);
var
aDir: string;
aDirs : TStringlist;
aFolderPath: string;
i: integer;
aItemPath: string;
aItemHash: string;
acalif: string;
aSizeMb: integer;
aAlbum: TRAlbum;
begin
 falbums.free;
 CreateLAlbumsFromDir(fdeffolder);
 FillStringGrid;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
   ainifile: TIniFile;
begin
  forder := false;
  ainifile := TINIFile.Create('DB.ini');
  fdeffolder := ainifile.ReadString('General','defaultfolder','');
  fexecutable := ainifile.ReadString('Player','playerpath','');
  fcmd := ainifile.ReadString('Player','playercmd','');

  ainifile.free;
end;

procedure TfrmMain.btnRepetidosClick(Sender: TObject);
var
   afreport: Tfreport;
begin
  afreport := TFreport.create(application);
  afreport.ffalbums := falbums;
  with afreport do
       show
end;

procedure TfrmMain.BtnFiltrarClick(Sender: TObject);
begin

end;



procedure TfrmMain.grdAlbumsClick(Sender: TObject);
var
   arow, acol: integer;
begin
 arow := grdAlbums.Row;
 acol := grdAlbums.Col;
 if ((arow = 0) and (acol =2)) then begin
    Sortlist('calific', ord(forder));
    forder := not(forder);
 end;

end;

procedure TfrmMain.grdAlbumsDblClick(Sender: TObject);
var
   AFolder: string;
   fila: integer;
   acalif: integer;
   aFile: textfile;
   aLine: string;
   fullpathcalif: string;
   AAlbum: TrAlbum;
begin
   fila := grdAlbums.Row;
   AFolder:= grdAlbums.Cells[1,fila ];
   if TfrmRating.getcalif(acalif) then begin
      //creamos un archivo de textodd ;
      fullpathcalif:= AFolder+ '\calificacion.txt';
      AssignFile(afile,fullpathcalif);
      rewrite(afile);
      aline :=FloatToStr(acalif/2);
      writeln(afile, aline);
      closefile(afile);
      AAlbum:= TRAlbum(falbums.items[fila-1]);
      AAlbum.fcalif:= acalif/2;
      FillStringGrid;

   end;

end;

procedure TfrmMain.grdAlbumsHeaderClick(Sender: TObject; IsColumn: Boolean;
  Index: Integer);
var
   arow, acol: integer;
begin
 if (iscolumn and (index =2)) then begin
    Sortlist('calific', ord(forder));
    forder := not(forder);
    FillStringGrid;
 end;

end;

procedure TfrmMain.grdAlbumsKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
   AFolder: String;
   process: TProcess;
   fila: integer;
begin
  fila := grdAlbums.Row;
  AFolder:= grdAlbums.Cells[1,fila ];
  if key = ord('P') then begin
     Process := TProcess.Create(nil);
     try
       Process.Executable := fexecutable;
       Process.Parameters.Add(fcmd);
       Process.Parameters.Add(aFolder);
       Process.Options := Process.Options + [poWaitOnExit];
       Process.Execute;
     finally
       Process.Free;
     end;
  end;
end;

procedure TfrmMain.CreateLalbumsFromDir(ADir: string);
var
aDirs : TStringlist;
i: integer;
aItemPath: string;
aItemHash: string;
acalif: string;
aSizeMb: integer;
aAlbum: TRAlbum;
begin
aDirs := TStringList.Create;
fAlbums := TList.create;

try
  if falbums = nil then begin
     falbums:= TList.create;
  end
     else begin
          FAlbums.free;
          fAlbums:= TList.create;
  end;

  FindAllDirectories(aDirs, aDir,  false); //find e.g. all pascal sourcefiles
  for i := 0 to aDirs.count-1 do begin
      aItemPath:= aDirs.Strings[i];
      aItemHash:= getFolderHash(aItemPath, 'calificacion.txt', asizeMb);
      acalif := getCalif(aItempath);
      // creamos un item del tipo tralbum
      aAlbum := TRAlbum.create;
      aAlbum.fAlbum:= aItemPath;
      aAlbum.fshortAlb := ExtractFileName(aItemPath);
      aAlbum.fcalif := StrToFloat(acalif);
      aAlbum.ftamano:= aSizeMb;
      aAlbum.fmd5 := aItemHash;
      fAlbums.add(aAlbum);
  end;
  ShowMessage(Format('Found %d directorios de albums', [aDirs.Count]));
finally
  aDirs.Free;
end;
end;

procedure TfrmMain.FillStringGrid;
var
AAlbum: TRAlbum;
i: integer;
begin
  grdAlbums.clear;
  grdAlbums.RowCount:=2;
  if Assigned(falbums) then begin
     for i:= 0 to falbums.count-1 do begin
         aalbum:= TrAlbum(falbums.Items[i]);
         grdAlbums.cells[1,i+1]:= aalbum.fAlbum;
         grdAlbums.cells[2,i+1]:= FloatToStr(aalbum.fcalif);
         grdAlbums.cells[3,i+1]:= IntToStr(aalbum.ftamano);
         grdAlbums.cells[4,i+1]:= aalbum.fmd5;
         grdAlbums.Rowcount:=grdAlbums.rowcount+1;

     end;
     grdAlbums.AutoSizeColumn(1);
     grdAlbums.AutoSizeColumn(4);
  end;

end;

procedure TfrmMain.ExcludeDiferents(ACriter: string);
var
   i: integer;
begin
  for i:= 0 to falbums.count-1 do begin

  end;
end;

procedure TfrmMain.Sortlist(ACritery: string; aOrder: integer);  //0 ascendente 1 descendete
var
   afirstalb, anextalb: trAlbum;
   i,j: integer;
   tempo: tralbum;
   firstcalif, secondcalif: double;
begin
  if ACritery= 'calific' then
     if Assigned(falbums) then
        for i:= 0 to falbums.count-2 do begin
            for j:= i+1 to falbums.count-1 do begin
                afirstalb:= TRAlbum(falbums.items[i]);
                firstcalif:= afirstalb.fcalif;
                anextalb:= TRAlbum(falbums.items[j]);
                secondcalif:= anextalb.fcalif;
                if AOrder = 0 then begin
                   if firstcalif > secondcalif then begin
                      tempo:= TRAlbum.create;
                      tempo.fAlbum:= afirstalb.fAlbum;
                      tempo.fcalif:= afirstalb.fcalif;
                      tempo.ftamano:=afirstalb.ftamano;
                      tempo.fmd5:= afirstalb.fmd5;
                      tempo.fShortAlb:=afirstalb.fShortAlb;

                      afirstalb.falbum:= anextalb.falbum;
                      afirstalb.fcalif:= anextalb.fcalif;
                      afirstalb.ftamano:= anextalb.ftamano;
                      afirstalb.fmd5:= anextalb.fmd5;
                      afirstalb.fShortAlb:=anextalb.fShortAlb;

                      anextalb.fAlbum:= tempo.fAlbum;
                      anextalb.fcalif:= tempo.fcalif;
                      anextalb.ftamano:= tempo.ftamano;
                      anextalb.fmd5:= tempo.fmd5;
                      anextalb.fShortAlb:=tempo.fShortAlb;
                      tempo.Free;
                   end
                end
                    else
                begin
                   if firstcalif < secondcalif then begin
                      tempo:= TRAlbum.create;
                      tempo.fAlbum:= afirstalb.fAlbum;
                      tempo.fcalif:= afirstalb.fcalif;
                      tempo.ftamano:=afirstalb.ftamano;
                      tempo.fmd5:= afirstalb.fmd5;
                      tempo.fShortAlb:=afirstalb.fShortAlb;

                      afirstalb.falbum:= anextalb.falbum;
                      afirstalb.fcalif:= anextalb.fcalif;
                      afirstalb.ftamano:= anextalb.ftamano;
                      afirstalb.fmd5:= anextalb.fmd5;
                      afirstalb.fShortAlb:=anextalb.fShortAlb;

                      anextalb.fAlbum:= tempo.fAlbum;
                      anextalb.fcalif:= tempo.fcalif;
                      anextalb.ftamano:= tempo.ftamano;
                      anextalb.fmd5:= tempo.fmd5;
                      anextalb.fShortAlb:=tempo.fShortAlb;
                      tempo.Free;
                   end
                end;
            end;
        end;
end;




end.

