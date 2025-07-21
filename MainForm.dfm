object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'G'#252'venli Notlar'
  ClientHeight = 600
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 350
    Top = 41
    Height = 540
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 41
    Align = alTop
    TabOrder = 0
    object ToolBar1: TToolBar
      Left = 1
      Top = 1
      Width = 898
      Height = 39
      ButtonWidth = 61
      Caption = 'ToolBar1'
      DrawingStyle = dsGradient
      EdgeBorders = [ebTop, ebBottom]
      Images = ImageList1
      List = True
      ShowCaptions = True
      TabOrder = 0
      object btnNew: TToolButton
        Left = 0
        Top = 0
        Hint = 'Yeni Not'
        Caption = 'Yeni'
        ImageIndex = 0
        OnClick = btnNewClick
      end
      object btnSave: TToolButton
        Left = 61
        Top = 0
        Hint = 'Kaydet'
        Caption = 'Kaydet'
        ImageIndex = 1
        OnClick = btnSaveClick
      end
      object btnDelete: TToolButton
        Left = 122
        Top = 0
        Hint = 'Sil'
        Caption = 'Sil'
        ImageIndex = 2
        OnClick = btnDeleteClick
      end
      object ToolButton1: TToolButton
        Left = 183
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object btnSearch: TToolButton
        Left = 191
        Top = 0
        Hint = 'Ara'
        Caption = 'Ara'
        ImageIndex = 3
      end
    end
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 41
    Width = 350
    Height = 540
    Align = alLeft
    TabOrder = 1
    object lvNotes: TListView
      Left = 1
      Top = 1
      Width = 348
      Height = 538
      Align = alClient
      Columns = <>
      TabOrder = 0
      OnSelectItem = lvNotesSelectItem
    end
  end
  object pnlRight: TPanel
    Left = 353
    Top = 41
    Width = 547
    Height = 540
    Align = alClient
    TabOrder = 2
    object pnlNoteHeader: TPanel
      Left = 1
      Top = 1
      Width = 545
      Height = 120
      Align = alTop
      TabOrder = 0
      object lblTitle: TLabel
        Left = 8
        Top = 8
        Width = 26
        Height = 13
        Caption = 'Ba'#351'l'#305'k'
      end
      object lblCategory: TLabel
        Left = 320
        Top = 8
        Width = 44
        Height = 13
        Caption = 'Kategori:'
      end
      object lblTags: TLabel
        Left = 8
        Top = 60
        Width = 114
        Height = 13
        Caption = 'Etiketler (Virg'#252'lle Ay'#305'r'#305'n)'
      end
      object edtTitle: TEdit
        Left = 8
        Top = 28
        Width = 300
        Height = 21
        TabOrder = 0
        OnChange = edtTitleChange
      end
      object cmbNoteCategory: TComboBox
        Left = 320
        Top = 28
        Width = 150
        Height = 21
        Style = csDropDownList
        TabOrder = 1
      end
      object edtTags: TEdit
        Left = 8
        Top = 80
        Width = 462
        Height = 21
        TabOrder = 2
      end
    end
    object memoContent: TMemo
      Left = 1
      Top = 121
      Width = 545
      Height = 418
      Align = alClient
      ScrollBars = ssVertical
      TabOrder = 1
      OnChange = memoContentChange
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 581
    Width = 900
    Height = 19
    Panels = <>
  end
  object edtSearch: TEdit
    Left = 200
    Top = 10
    Width = 150
    Height = 21
    TabOrder = 4
    TextHint = 'Ara...'
    OnChange = edtSearchChange
  end
  object cmbCategory: TComboBox
    Left = 370
    Top = 10
    Width = 150
    Height = 21
    Style = csDropDownList
    TabOrder = 5
    OnChange = cmbCategoryChange
  end
  object MainMenu1: TMainMenu
    Left = 24
    Top = 88
    object mnuFile: TMenuItem
      Caption = '&Dosya'
      object mnuNew: TMenuItem
        Caption = '&Yeni Not'
        ShortCut = 16462
        OnClick = btnNewClick
      end
      object mnuSave: TMenuItem
        Caption = '&Kaydet'
        ShortCut = 16467
        OnClick = btnSaveClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnuBackup: TMenuItem
        Caption = '&Yedekle...'
        OnClick = mnuBackupClick
      end
      object mnuRestore: TMenuItem
        Caption = 'Geri Y'#252'kle'
        OnClick = mnuRestoreClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mnuExit: TMenuItem
        Caption = #199#305'k'#305#351
        OnClick = mnuExitClick
      end
    end
    object mnuEdit: TMenuItem
      Caption = 'D'#252'zenle'
      object mnuCategory: TMenuItem
        Caption = '&Kategoriler'
        object mnuAddCategory: TMenuItem
          Caption = 'Yeni &Kategori...'
          OnClick = mnuAddCategoryClick
        end
        object mnuManageCategories: TMenuItem
          Caption = 'Kategorileri Y'#246'net'
          OnClick = mnuManageCategoriesClick
        end
      end
    end
    object mnuTools: TMenuItem
      Caption = 'Ara'#231'lar'
      object mnuChangePassword: TMenuItem
        Caption = #350'ifre De'#287'i'#351'tir'
        OnClick = mnuChangePasswordClick
      end
    end
  end
  object ImageList1: TImageList
    Left = 88
    Top = 88
  end
  object SaveDialog1: TSaveDialog
    Left = 152
    Top = 88
  end
  object OpenDialog1: TOpenDialog
    Left = 216
    Top = 88
  end
end
