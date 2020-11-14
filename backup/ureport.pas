unit ureport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, lcltype,fileutil;

type

  { TfReport }

  TfReport = class(TForm)
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    StatusBar1: TStatusBar;

    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure ListBox1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    fpath: string;
    function isInlist(AaDir: string; var posit: integer): boolean;

  public
    ffAlbums: TList;
  end;



implementation

uses ufolderHash;

{$R *.lfm}

{ TfReport }

function TfReport.isInlist(AaDir: string; var posit: integer): boolean;
var
   aAlbum: TRAlbum;
   asl: TStringList;
   i,idx: integer;
begin
   asl:= TStringList.create;
   for i:= 0 to ffAlbums.Count-1 do begin
       aAlbum:= TRAlbum(ffAlbums.Items[i]);
       asl.Add(aalbum.fshortalb);
   end;
   idx:= asl.IndexOf(AaDir);
   result := (idx <> -1);
   if result then
      posit := idx;
   asl.free;

end;

procedure TfReport.FormDropFiles(Sender: TObject;
  const FileNames: array of String);

var
   i,j: integer;
   adirdraged, adirorig : string;
   posit: integer;
   aalbum: tralbum;
   aHashDraged, aHashOrig: string;
   ADirDragedLong: string;
   aSize: integer;
begin
   j:= 0;
   fpath:= ExtractFileDir(Filenames[0]);
   for i := Low(FileNames) to High(FileNames) do begin
       adirdragedLOng := filenames[i];
       aDirDraged := extractFileName(adirdragedLong);
       if isInlist(adirdraged, posit) then begin
          // ya averigue que la carpeta existe, ahora averiguare si el directorio arrastrado tiene el mismo hash que el que esta en mi bd
         aalbum:= TRAlbum(ffAlbums.items[posit]);
         adirorig:= aalbum.fAlbum;
         aHashOrig:= aalbum.fmd5;
         aHashDraged := getFolderHash(aDirDragedLong,'calificacion.txt',aSize);
         if (aHashOrig = aHashDraged) then begin
            listbox1.items.add(adirdraged);
            inc(j);
            StatusBar1.Panels[0].Text:= IntToStr(j) + ' archivos';
         end;

       end;

   end;

end;

procedure TfReport.ListBox1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
   fulldirpath: string;
begin
  if key = vk_delete then begin
     fulldirpath:=  fpath + '\' + listbox1.Items[listbox1.itemindex];
     DeleteDirectory(fulldirpath,false);
     listbox1.DeleteSelected;
  end;

end;




end.

