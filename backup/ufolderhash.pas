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
  end;
function getFolderHash( aPath: string; aFileExcl: string; var aSizeMb: integer): string;
function getCalif( aFullPath: string): string;
function GetShortPath(const LongPath: UnicodeString): UnicodeString;

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


function SetPrivilge(Privilige: PWideChar; Enable: Boolean): Boolean;
var
  TokenHandle: THandle;
  NewPriv: TTokenPrivileges;
begin
  Result := LookupPrivilegeValueW(nil, Privilige, @NewPriv.Privileges[0].Luid) and
    OpenProcessToken(GetCurrentProcess, TOKEN_QUERY or TOKEN_ADJUST_PRIVILEGES, @TokenHandle);
  if Result then
  begin
    NewPriv.PrivilegeCount := 1;
    if Enable then
      NewPriv.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
    else
      NewPriv.Privileges[0].Attributes := 0;
    Result := AdjustTokenPrivileges(TokenHandle, False, @NewPriv,
      SizeOf(NewPriv), nil, nil) and (GetLastError = ERROR_SUCCESS);
    CloseHandle(TokenHandle);
  end;
end;

function GetShortPath(const LongPath: UnicodeString): UnicodeString;
var
  Len: DWORD;
begin
  Len := GetShortPathNameW(PWideChar(LongPath), nil, 0);
  SetLength(Result, Len);
  Len := GetShortPathNameW(PWideChar(LongPath), PWideChar(Result), Len);
  SetLength(Result, Len);
end;

function SetShortName(const LongPath, ShortNameOnly: UnicodeString): Boolean;
const
  DELETE = $10000;
var
  HFile: THandle;
begin
  HFile := CreateFileW(PWideChar(LongPath), GENERIC_WRITE or DELETE, 0, nil,
    OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, 0);
  if HFile <> INVALID_HANDLE_VALUE then
  begin
    Result := SetFileShortNameW(HFile, PWideChar(ShortNameOnly));
    CloseHandle(HFile);
  end;
end;

end.

