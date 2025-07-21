unit PasswordDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmPassword = class(TForm)
    Panel1: TPanel;
    edtPassword: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    chkShowPassword: TCheckBox;
    edtConfirm: TEdit;
    lblConfirm: TLabel;
    procedure chkShowPasswordClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    FConfirmRequired: Boolean;
  public
    class function Execute(const ATitle: string; var APassword: string; AConfirmRequired: Boolean): Boolean;
  end;

implementation

{$R *.dfm}

class function TfrmPassword.Execute(const ATitle: string; var APassword: string; AConfirmRequired: Boolean): Boolean;
var
  frm: TfrmPassword;
begin
  frm := TfrmPassword.Create(nil);
  try
    frm.Caption := ATitle;
    frm.FConfirmRequired := AConfirmRequired;
    frm.lblConfirm.Visible := AConfirmRequired;
    frm.edtConfirm.Visible := AConfirmRequired;
    
    if not AConfirmRequired then
      frm.Height := 180
    else
      frm.Height := 220;
      
    Result := frm.ShowModal = mrOK;
    if Result then
      APassword := frm.edtPassword.Text;
  finally
    frm.Free;
  end;
end;

procedure TfrmPassword.btnOKClick(Sender: TObject);
begin
  if Trim(edtPassword.Text) = '' then
  begin
    MessageDlg('Şifre boş olamaz!', mtError, [mbOK], 0);
    edtPassword.SetFocus;
    Exit;
  end;
  
  if FConfirmRequired then
  begin
    if edtPassword.Text <> edtConfirm.Text then
    begin
      MessageDlg('Şifreler uyuşmuyor!', mtError, [mbOK], 0);
      edtConfirm.SetFocus;
      edtConfirm.SelectAll;
      Exit;
    end;
  end;
  
  ModalResult := mrOK;
end;

procedure TfrmPassword.chkShowPasswordClick(Sender: TObject);
begin
  if chkShowPassword.Checked then
  begin
    edtPassword.PasswordChar := #0;
    edtConfirm.PasswordChar := #0;
  end
  else
  begin
    edtPassword.PasswordChar := '*';
    edtConfirm.PasswordChar := '*';
  end;
end;

procedure TfrmPassword.FormShow(Sender: TObject);
begin
  edtPassword.SetFocus;
end;

end.