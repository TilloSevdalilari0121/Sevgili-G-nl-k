unit SettingsDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, DataModel;

type
  TfrmSettings = class(TForm)
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    chkAutoSave: TCheckBox;
    Label1: TLabel;
    edtAutoSaveInterval: TEdit;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure chkAutoSaveClick(Sender: TObject);
  private
    FNoteManager: TNoteManager;
  public
    property NoteManager: TNoteManager read FNoteManager write FNoteManager;
  end;

function ShowSettingsDialog(ANoteManager: TNoteManager): Boolean;

implementation

{$R *.dfm}

function ShowSettingsDialog(ANoteManager: TNoteManager): Boolean;
var
  frm: TfrmSettings;
begin
  frm := TfrmSettings.Create(nil);
  try
    frm.NoteManager := ANoteManager;
    frm.chkAutoSave.Checked := ANoteManager.AutoSaveTimer.Enabled;
    frm.edtAutoSaveInterval.Text := IntToStr(ANoteManager.AutoSaveTimer.Interval div 1000);
    
    Result := frm.ShowModal = mrOK;
    
    if Result then
    begin
      if frm.chkAutoSave.Checked then
        ANoteManager.EnableAutoSave(StrToIntDef(frm.edtAutoSaveInterval.Text, 300))
      else
        ANoteManager.DisableAutoSave;
    end;
  finally
    frm.Free;
  end;
end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
  Position := poMainFormCenter;
end;

procedure TfrmSettings.chkAutoSaveClick(Sender: TObject);
begin
  edtAutoSaveInterval.Enabled := chkAutoSave.Checked;
end;

end.