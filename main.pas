unit Main;

{$mode objfpc}{$H+}{$J-}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  FileUtil, Utils;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnDecompress: TButton;
    btnCompress: TButton;
    btnBrowseInDir: TButton;
    btnBrowseOutDir: TButton;
    btnAbout: TButton;
    cbMipmaps: TCheckBox;
    edtOutDir: TEdit;
    edtInDir: TEdit;
    lblStatus: TLabel;
    lblOutDir: TLabel;
    lblInDir: TLabel;
    lblMessage: TLabel;
    rgCompressionType: TRadioGroup;
    dlgSelectOutDir: TSelectDirectoryDialog;
    dlgSelectInDir: TSelectDirectoryDialog;
    procedure btnBrowseInDirClick(Sender: TObject);
    procedure btnBrowseOutDirClick(Sender: TObject);
    procedure btnCompressClick(Sender: TObject);
    procedure btnDecompressClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure cbMipmapsChange(Sender: TObject);
    procedure edtInDirChange(Sender: TObject);
    procedure edtOutDirChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rgCompressionTypeSelectionChanged(Sender: TObject);
  private
    Config: TConfig;
    function InOutDirsPresent: boolean;
  public

  end;

const
  TITLE: string = 'RomeTexTools';
  VERSION: string = 'v1.0.1';
  AUTHOR: string = 'Vartan Haghverdi';
  COPYRIGHT: string = 'Copyright 2023';
  NOTE: string = 'Brought to you by the EB Online Team';

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.btnBrowseInDirClick(Sender: TObject);
begin
  if dlgSelectInDir.Execute then
    edtInDir.Text := dlgSelectInDir.FileName;
end;

procedure TfrmMain.btnBrowseOutDirClick(Sender: TObject);
begin
  if dlgSelectOutDir.Execute then
    edtOutDir.Text := dlgSelectOutDir.FileName;
end;

procedure TfrmMain.btnCompressClick(Sender: TObject);
begin
  if not InOutDirsPresent then
  begin
    ShowMessage('Please select both an input and output folder before continuing.');
    Exit();
  end;

  btnCompress.Enabled := False;
  btnDecompress.Enabled := False;
  lblStatus.Caption := 'Status: compressing...';
  Application.ProcessMessages;
  CompressDirToDDS(Config);
  RunLZ4InDir(Config.OutDir);
  RemoveLZ4ExtInDir(Config.OutDir);
  btnCompress.Enabled := True;
  btnDecompress.Enabled := True;
  lblStatus.Caption := 'Status: compression complete';
end;

procedure TfrmMain.btnDecompressClick(Sender: TObject);
begin
  if not InOutDirsPresent then
  begin
    ShowMessage('Please select both an input and output folder before continuing.');
    Exit();
  end;

  btnCompress.Enabled := False;
  btnDecompress.Enabled := False;
  lblStatus.Caption := 'Status: decompressing...';
  Application.ProcessMessages;
  DecompressDirToDDS(Config);
  btnCompress.Enabled := True;
  btnDecompress.Enabled := True;
  lblStatus.Caption := 'Status: decompression complete';
end;

procedure TfrmMain.btnAboutClick(Sender: TObject);
begin
  ShowMessage(TITLE + ' ' + VERSION + LineEnding + NOTE + LineEnding +
    COPYRIGHT + ' ' + AUTHOR);
end;

procedure TfrmMain.cbMipmapsChange(Sender: TObject);
begin
  Config.Mipmaps := cbMipmaps.Checked;
end;

procedure TfrmMain.edtInDirChange(Sender: TObject);
begin
  Config.InDir := Trim(edtInDir.Text);
end;

procedure TfrmMain.edtOutDirChange(Sender: TObject);
begin
  Config.OutDir := Trim(edtOutDir.Text);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  frmMain.Caption := TITLE + ' ' + VERSION;
  Config.Mipmaps := True;
  cbMipmaps.Checked := Config.Mipmaps;
  Config.CompressionType := ctDXT5;
  rgCompressionType.ItemIndex := Ord(Config.CompressionType);
end;

procedure TfrmMain.rgCompressionTypeSelectionChanged(Sender: TObject);
begin
  case rgCompressionType.Items[rgCompressionType.ItemIndex] of
    'DXT5': Config.CompressionType := ctDXT5;
    'DXT1': Config.CompressionType := ctDXT1;
  end;
end;

function TfrmMain.InOutDirsPresent: boolean;
begin
  Result := (Config.InDir <> '') and (Config.OutDir <> '');
end;

end.
