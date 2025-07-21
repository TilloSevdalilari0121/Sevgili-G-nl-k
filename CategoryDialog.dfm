object frmCategoryManager: TfrmCategoryManager
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Kategori Y'#246'netimi'
  ClientHeight = 400
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  object Panel1: TPanel
    Left = 0
    Top = 354
    Width = 400
    Height = 46
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnAdd: TButton
      Left = 8
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Ekle...'
      TabOrder = 0
      OnClick = btnAddClick
    end
    object btnEdit: TButton
      Left = 89
      Top = 10
      Width = 75
      Height = 25
      Caption = 'D'#252'zenle...'
      TabOrder = 1
      OnClick = btnEditClick
    end
    object btnDelete: TButton
      Left = 170
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Sil'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnClose: TButton
      Left = 317
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Kapat'
      TabOrder = 3
      OnClick = btnCloseClick
    end
  end
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 400
    Height = 354
    Align = alClient
    Columns = <>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnCustomDrawItem = ListView1CustomDrawItem
    OnDblClick = ListView1DblClick
  end
  object ColorDialog1: TColorDialog
    Left = 16
    Top = 16
  end
end