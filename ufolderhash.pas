unit ufolderHash;

{$mode objfpc}{$H+}


interface

uses
  Classes, SysUtils, FileUtil, Dialogs, Md5, jwaWinBase, Windows;

type

    { TRAlbum}
  TRAlbum = class
    fAlbum: string;
    fShortAlb: string;
    fcalif: double;
    ftamano: integer;
    fmd5: string;
    fvisible: boolean;
  end;
function getFolderHash( aPath: string; aFileExcl: string; var aSizeMb: integer): string;
function getCalif( aFullPath: string): string;

implementation



function getFolderHash( aPath: string; aFileExcl: string; var aSizeMb: integer): string;
var
  AList: TStringList;
  i: integer;
  idx: integer;
  aItem, aItemFixed: string;
  aSize, aSizeAcum: dWord;
  f: file of byte;
  fullfilepath: string;
begin
  ASizeAcum:= 0;
  Result := '';
  Alist := TStringlist.create;

  try
    FindAllFiles(AList, aPath, '*.*', false);

    //reconfiguramos AList solo con los nombres de archivos;
    for i:= 0 to AList.count-1 do begin
      aItem:= AList.Strings[i];
      aItemFixed := ExtractfileName(aitem);
      AList.Strings[i]:= aItemFixed;
    end;
    AList.Sort;
    // borramos  los archivos que no me interesa contabilizar
    idx := AList.IndexOf('Thumbs.db');
    if (idx <> -1) then
       AList.Delete(idx);
    idx := AList.IndexOf(aFileExcl);
    if (idx <> -1) then
        AList.Delete(idx);

    for i:= 0 to AList.count-1 do begin
        aItem:= AList.Strings[i];
        fullfilepath:= apath + '\' + aItem;
        assignfile(f,fullfilepath);
        reset(f);
        asize:= filesize(f);
        closefile(f);
        aSizeAcum:= ASizeAcum + asize;

    end;

    for i := 0 to AList.count-1 do begin
      aItem:= AList.Strings[i];
      Result := Result + aItem + ' ; ';
    end;
    aSizeMb := ((aSizeAcum div 1024 ) div 1024);
    Result := Result + IntToStr(aSizeAcum);

  finally
    AList.Free;
    Result:= MD5Print(MD5String(Result));
  end;

end;

function getCalif( aFullPath: string): string;
var
  txtfile: TextFile;
  acalif: string;
  aFullPathFile: string;
begin
  AFullPathFile := AFullPath + '\calificacion.txt';
  if FileExists(AfullPathFile) then
  begin
     AssignFile(txtfile,aFullPathFile);
     try
        Reset(txtfile);
        readln(txtfile,acalif);
     finally
        closefile(txtfile);
     end;
  result := acalif;
  end
      else
  result := IntToStr(-1);
end;



end.

