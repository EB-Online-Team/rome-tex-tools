unit Utils;

{$mode ObjFPC}{$H+}{$J-}

interface

uses
  Classes, SysUtils, StrUtils, process, FileUtil;

type
  TCompressionType = (ctDXT5, ctDXT1);

  TConfig = record
    InDir: string;
    OutDir: string;
    CompressionType: TCompressionType;
    Mipmaps: boolean;
  end;

function DirTreeWithMask(InDir, OutDir: string; SearchMask: string = ''): TStringList;
function LZ4Compressed(const Filename: string): boolean;
function CompressDirToDDS(const Config: TConfig): boolean;
function RunLZ4InDir(const Dir: string; const Compress: boolean = True): boolean;
function RemoveLZ4ExtInDir(const Dir: string): boolean;
function AddLZ4ExtInDir(const Dir: string): boolean;
procedure DecompressDirToDDS(const Config: TConfig);

implementation

function DirTreeWithMask(InDir, OutDir: string; SearchMask: string = ''): TStringList;
var
  InFiles, OutFiles: TStringList;
  InFile: string;
begin
  OutFiles := TStringList.Create;
  InFiles := FindAllFiles(InDir, SearchMask);

  // swap the base input directory with the output directory, thus preserving the source tree
  for  InFile in InFiles do
    OutFiles.Add(OutDir + InFile.Substring(Length(InDir)));

  FreeAndNil(InFiles);
  Exit(OutFiles);
end;

function LZ4Compressed(const Filename: string): boolean;
var
  Output: string;
begin
  Exit(RunCommand('.\lz4.exe', ['-t', Filename], Output, [], swoHIDE));
end;

function CompressDirToDDS(const Config: TConfig): boolean;
var
  Output, Format, Mipmaps: string;
  Options: array of TProcessString;
begin
  case Config.CompressionType of
    ctDXT5: Format := 'DXT5';
    ctDXT1: Format := 'DXT1';
    else
      Format := 'DXT5';
  end;

  Mipmaps := IfThen(Config.Mipmaps, '0', '1');
  Options := ['-m', Mipmaps, '-r:keep', '-l', '-y', '-f', Format,
    Config.InDir + '\*', '-o', Config.OutDir];
  Exit(RunCommand('.\texconv.exe', Options, Output, [], swoHIDE));
end;

function RunLZ4InDir(const Dir: string; const Compress: boolean = True): boolean;
var
  Output: string;
begin
  if Compress then
    Exit(RunCommand('.\lz4.exe', ['-rfz', '-B4', '--best', '--rm', Dir + '\*'],
      Output, [], swoHIDE))
  else
    Exit(RunCommand('.\lz4.exe', ['-rfd', '--rm', Dir + '\*'], Output,
      [], swoHIDE));
end;

function RemoveLZ4ExtInDir(const Dir: string): boolean;
var
  Output: string;
begin
  Exit(RunCommand('forfiles', ['/P', Dir, '/M', '*.lz4', '/S',
    '/C "cmd /c ren @file @fname"'], Output, [], swoHIDE));
end;

function AddLZ4ExtInDir(const Dir: string): boolean;
var
  Output: string;
begin
  Exit(RunCommand('forfiles', ['/P', Dir, '/M', '*.dds', '/S',
    '/C "cmd /c ren @file @file.lz4"'], Output, [], swoHIDE));
end;

procedure DecompressDirToDDS(const Config: TConfig);
begin
  CopyDirTree(Config.InDir, Config.OutDir,
    [cffOverwriteFile, cffCreateDestDirectory, cffPreserveTime]);
  AddLZ4ExtInDir(Config.OutDir);
  RunLZ4InDir(Config.OutDir, False);
end;

end.
