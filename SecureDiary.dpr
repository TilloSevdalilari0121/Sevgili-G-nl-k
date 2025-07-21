program SecureDiary;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {frmMain},
  DataModel in 'DataModel.pas',
  EncryptionUnit in 'EncryptionUnit.pas',
  PasswordDialog in 'PasswordDialog.pas' {frmPassword},
  CategoryDialog in 'CategoryDialog.pas' {frmCategoryManager},
  SettingsDialog in 'SettingsDialog.pas' {frmSettings};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Güvenli Günlük';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.