object frmPassword: TfrmPassword
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #350'ifre'
  ClientHeight = 180
  ClientWidth = 350
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 350
    Height = 180
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 26
      Height = 15
      Caption = #350'ifre:'
    end
    object lblConfirm: TLabel
      Left = 16
      Top = 68
      Width = 68
      Height = 15
      Caption = #350'ifre (Tekrar):'
    end
    object edtPassword: TEdit
      Left = 16
      Top = 37
      Width = 318
      Height = 23
      PasswordChar = '*'
      TabOrder = 0
    end
    object btnOK: TButton
      Left = 178
      Top = 139
      Width = 75
      Height = 25
      Caption = 'Tamam'
      Default = True
      TabOrder = 3
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 259
      Top = 139
      Width = 75
      Height = 25
      Cancel = True
      Caption = #304'ptal'
      ModalResult = 2
      TabOrder = 4
    end
    object chkShowPassword: TCheckBox
      Left = 16
      Top = 120
      Width = 121
      Height = 17
      Caption = #350'ifreyi G'#246'ster'
      TabOrder = 2
      OnClick = chkShowPasswordClick
    end
    object edtConfirm: TEdit
      Left = 16
      Top = 89
      Width = 318
      Height = 23
      PasswordChar = '*'
      TabOrder = 1
    end
  end
end