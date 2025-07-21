object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Ayarlar'
  ClientHeight = 200
  ClientWidth = 350
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  object Panel1: TPanel
    Left = 0
    Top = 159
    Width = 350
    Height = 41
    Align = alBottom
    TabOrder = 0
    object btnOK: TButton
      Left = 188
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Tamam'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 269
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'İptal'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 334
    Height = 145
    Caption = 'Otomatik Kaydetme'
    TabOrder = 1
    object Label1: TLabel
      Left = 40
      Top = 56
      Width = 86
      Height = 13
      Caption = 'Kaydetme Aralığı:'
    end
    object Label2: TLabel
      Left = 192
      Top = 56
      Width = 32
      Height = 13
      Caption = 'saniye'
    end
    object chkAutoSave: TCheckBox
      Left = 16
      Top = 24
      Width = 161
      Height = 17
      Caption = 'Otomatik Kaydetmeyi Etkinleştir'
      TabOrder = 0
      OnClick = chkAutoSaveClick
    end
    object edtAutoSaveInterval: TEdit
      Left = 132
      Top = 53
      Width = 53
      Height = 21
      TabOrder = 1
      Text = '300'
    end
  end
end