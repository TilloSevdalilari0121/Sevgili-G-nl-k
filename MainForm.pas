unit MainForm;

{**
  ********************************************************************
  *                                                                  *
  *    Bismillahirrahmanirrahim                                      *
  *    In the Name of Allah, the Most Gracious, the Most Merciful    *
  *                                                                  *
  ********************************************************************
}


interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Menus, Vcl.ToolWin,
  Vcl.ImgList, System.ImageList, DataModel, System.Generics.Collections;

type
  TfrmMain = class(TForm)
    pnlTop: TPanel;
    ToolBar1: TToolBar;
    btnNew: TToolButton;
    btnSave: TToolButton;
    btnDelete: TToolButton;
    ToolButton1: TToolButton;
    btnSearch: TToolButton;
    edtSearch: TEdit;
    cmbCategory: TComboBox;
    pnlLeft: TPanel;
    lvNotes: TListView;
    Splitter1: TSplitter;
    pnlRight: TPanel;
    pnlNoteHeader: TPanel;
    lblTitle: TLabel;
    edtTitle: TEdit;
    lblCategory: TLabel;
    cmbNoteCategory: TComboBox;
    lblTags: TLabel;
    edtTags: TEdit;
    memoContent: TMemo;
    StatusBar1: TStatusBar;
    MainMenu1: TMainMenu;
    mnuFile: TMenuItem;
    mnuNew: TMenuItem;
    mnuSave: TMenuItem;
    N1: TMenuItem;
    mnuBackup: TMenuItem;
    mnuRestore: TMenuItem;
    N2: TMenuItem;
    mnuExit: TMenuItem;
    mnuEdit: TMenuItem;
    mnuCategory: TMenuItem;
    mnuAddCategory: TMenuItem;
    mnuManageCategories: TMenuItem;
    mnuTools: TMenuItem;
    mnuChangePassword: TMenuItem;
    ImageList1: TImageList;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnNewClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure lvNotesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure edtTitleChange(Sender: TObject);
    procedure memoContentChange(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure cmbCategoryChange(Sender: TObject);
    procedure mnuAddCategoryClick(Sender: TObject);
    procedure mnuManageCategoriesClick(Sender: TObject);
    procedure mnuBackupClick(Sender: TObject);
    procedure mnuRestoreClick(Sender: TObject);
    procedure mnuChangePasswordClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
  private
    FNoteManager: TNoteManager;
    FCurrentNote: TNote;
    FIsLoading: Boolean;
    procedure LoadNoteList;
    procedure LoadCategories;
    procedure DisplayNote(ANote: TNote);
    procedure ClearEditor;
    procedure UpdateStatusBar;
    procedure SaveCurrentNote;
   // function GetPassword: string;
    procedure SetupUI;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  PasswordDialog, CategoryDialog;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
var
  Password: string;
  DataFile: string;
  FileExists: Boolean;
begin
  FIsLoading := True;
  try
    SetupUI;
    DataFile := ExtractFilePath(Application.ExeName) + 'diary.enc';
    FileExists := System.SysUtils.FileExists(DataFile);

    // Şifre alma
    if FileExists then
    begin
      // Mevcut dosya var - şifre iste
      if not TfrmPassword.Execute('Günlük Şifresi', Password, False) then
      begin
        Application.Terminate;
        Exit;
      end;
    end
    else
    begin
      // Yeni dosya - şifre belirle
      if not TfrmPassword.Execute('Yeni Günlük - Şifre Belirleyin', Password, True) then
      begin
        Application.Terminate;
        Exit;
      end;
    end;

    // Şimdi NoteManager'ı oluştur ve veri yükle
    FNoteManager := TNoteManager.Create(DataFile);

    if not FNoteManager.LoadData(Password) then
    begin
      if FileExists then
        ShowMessage('Hatalı şifre!')
      else
        ShowMessage('Günlük oluşturulamadı!');
      Application.Terminate;
      Exit;
    end;

    FNoteManager.EnableAutoSave(300);
    LoadCategories;
    LoadNoteList;
    UpdateStatusBar;
  finally
    FIsLoading := False;
  end;
end;

procedure TfrmMain.SetupUI;
begin
  Caption := 'Güvenli Günlük';
  Position := poScreenCenter;
  Width := 1024;
  Height := 768;
  
  // Toolbar butonları
  btnNew.Caption := 'Yeni';
  btnNew.ShowHint := True;
  btnNew.Hint := 'Yeni Not';
  
  btnSave.Caption := 'Kaydet';
  btnSave.ShowHint := True;
  btnSave.Hint := 'Notu Kaydet';
  
  btnDelete.Caption := 'Sil';
  btnDelete.ShowHint := True;
  btnDelete.Hint := 'Notu Sil';
  
  // ListView ayarları
  lvNotes.ViewStyle := vsReport;
  lvNotes.ReadOnly := True;
  lvNotes.RowSelect := True;
  
  with lvNotes.Columns.Add do
  begin
    Caption := 'Başlık';
    Width := 200;
  end;
  
  with lvNotes.Columns.Add do
  begin
    Caption := 'Kategori';
    Width := 100;
  end;
  
  with lvNotes.Columns.Add do
  begin
    Caption := 'Tarih';
    Width := 120;
  end;
  
  // Durum çubuğu
  StatusBar1.SimplePanel := False;
  with StatusBar1.Panels.Add do
  begin
    Width := 200;
    Text := 'Hazır';
  end;
  
  with StatusBar1.Panels.Add do
  begin
    Width := 150;
    Text := 'Notlar: 0';
  end;
  
  with StatusBar1.Panels.Add do
  begin
    Width := 200;
    Text := 'Otomatik kayıt: Aktif';
  end;
  
  edtSearch.TextHint := 'Ara...';
  ClearEditor;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if Assigned(FNoteManager) then
  begin
    SaveCurrentNote;
    if FNoteManager.Modified then
      FNoteManager.SaveData;
    FNoteManager.Free;
  end;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(FNoteManager) and FNoteManager.Modified then
  begin
    case MessageDlg('Kaydedilmemiş değişiklikler var. Kaydetmek ister misiniz?',
      mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
      mrYes:
        begin
          SaveCurrentNote;
          FNoteManager.SaveData;
          CanClose := True;
        end;
      mrNo:
        CanClose := True;
      mrCancel:
        CanClose := False;
    end;
  end;
end;

//function TfrmMain.GetPassword: string;
//begin
  //if not FileExists(ExtractFilePath(Application.ExeName) + 'diary.enc') then
  //begin
    //if not TfrmPassword.Execute('Yeni Günlük - Şifre Belirleyin', Result, True) then
     // Result := '';
  //end
 // else
  //begin
   // if not TfrmPassword.Execute('Günlük Şifresi', Result, False) then
     // Result := '';
  //end;
//end;

procedure TfrmMain.LoadCategories;
var
  Category: TCategory;
begin
  cmbCategory.Items.Clear;
  cmbNoteCategory.Items.Clear;
  
  cmbCategory.Items.Add('Tüm Kategoriler');
  
  for Category in FNoteManager.Categories do
  begin
    cmbCategory.Items.AddObject(Category.Name, Category);
    cmbNoteCategory.Items.AddObject(Category.Name, Category);
  end;
  
  cmbCategory.ItemIndex := 0;
  if cmbNoteCategory.Items.Count > 0 then
    cmbNoteCategory.ItemIndex := 0;
end;

procedure TfrmMain.LoadNoteList;
var
  Note: TNote;
  Item: TListItem;
  Category: TCategory;
  CategoryName: string;
  SearchText: string;
  SelectedCategory: TCategory;
  ShowNote: Boolean;
begin
  lvNotes.Items.BeginUpdate;
  try
    lvNotes.Clear;
    
    SearchText := Trim(edtSearch.Text);
    SelectedCategory := nil;
    if (cmbCategory.ItemIndex > 0) and (cmbCategory.ItemIndex < cmbCategory.Items.Count) then
      SelectedCategory := TCategory(cmbCategory.Items.Objects[cmbCategory.ItemIndex]);
    
    for Note in FNoteManager.Notes do
    begin
      ShowNote := True;
      
      // Arama filtresi
      if SearchText <> '' then
      begin
        ShowNote := (Pos(LowerCase(SearchText), LowerCase(Note.Title)) > 0) or
                    (Pos(LowerCase(SearchText), LowerCase(Note.Content)) > 0) or
                    (Pos(LowerCase(SearchText), LowerCase(Note.Tags.DelimitedText)) > 0);
      end;
      
      // Kategori filtresi
      if ShowNote and Assigned(SelectedCategory) then
        ShowNote := (Note.CategoryID = SelectedCategory.ID);
      
      if ShowNote then
      begin
        Item := lvNotes.Items.Add;
        Item.Caption := Note.Title;
        Item.Data := Note;
        
        CategoryName := 'Genel';
        for Category in FNoteManager.Categories do
        begin
          if Category.ID = Note.CategoryID then
          begin
            CategoryName := Category.Name;
            Break;
          end;
        end;
        
        Item.SubItems.Add(CategoryName);
        Item.SubItems.Add(FormatDateTime('dd.mm.yyyy hh:nn', Note.ModifiedDate));
      end;
    end;
  finally
    lvNotes.Items.EndUpdate;
    UpdateStatusBar;
  end;
end;

procedure TfrmMain.DisplayNote(ANote: TNote);
var
  i: Integer;
begin
  FIsLoading := True;
  try
    FCurrentNote := ANote;
    
    if Assigned(ANote) then
    begin
      edtTitle.Text := ANote.Title;
      memoContent.Text := ANote.Content;
      edtTags.Text := ANote.Tags.DelimitedText;
      
      for i := 0 to cmbNoteCategory.Items.Count - 1 do
      begin
        if TCategory(cmbNoteCategory.Items.Objects[i]).ID = ANote.CategoryID then
        begin
          cmbNoteCategory.ItemIndex := i;
          Break;
        end;
      end;
      
      edtTitle.Enabled := True;
      memoContent.Enabled := True;
      cmbNoteCategory.Enabled := True;
      edtTags.Enabled := True;
      btnSave.Enabled := True;
      btnDelete.Enabled := True;
    end
    else
      ClearEditor;
  finally
    FIsLoading := False;
  end;
end;

procedure TfrmMain.ClearEditor;
begin
  FCurrentNote := nil;
  edtTitle.Clear;
  memoContent.Clear;
  edtTags.Clear;
  if cmbNoteCategory.Items.Count > 0 then
    cmbNoteCategory.ItemIndex := 0;
    
  edtTitle.Enabled := False;
  memoContent.Enabled := False;
  cmbNoteCategory.Enabled := False;
  edtTags.Enabled := False;
  btnSave.Enabled := False;
  btnDelete.Enabled := False;
end;

procedure TfrmMain.SaveCurrentNote;
begin
  if not Assigned(FCurrentNote) or FIsLoading then
    Exit;
    
  FCurrentNote.Title := edtTitle.Text;
  FCurrentNote.Content := memoContent.Text;
  FCurrentNote.Tags.DelimitedText := edtTags.Text;
  
  if cmbNoteCategory.ItemIndex >= 0 then
    FCurrentNote.CategoryID := TCategory(cmbNoteCategory.Items.Objects[cmbNoteCategory.ItemIndex]).ID;
    
  FNoteManager.UpdateNote(FCurrentNote);
end;

procedure TfrmMain.UpdateStatusBar;
begin
  StatusBar1.Panels[1].Text := Format('Notlar: %d', [FNoteManager.Notes.Count]);
  
  if FNoteManager.Modified then
    StatusBar1.Panels[0].Text := 'Değişiklikler var*'
  else
    StatusBar1.Panels[0].Text := 'Hazır';
end;

procedure TfrmMain.btnNewClick(Sender: TObject);
var
  Note: TNote;
  CategoryID: string;
  i: Integer;
begin
  SaveCurrentNote;
  
  CategoryID := '';
  if cmbNoteCategory.Items.Count > 0 then
    CategoryID := TCategory(cmbNoteCategory.Items.Objects[0]).ID;
    
  Note := FNoteManager.AddNote('Yeni Not', '', CategoryID);
  
  LoadNoteList;
  
  // Yeni notu bul ve seç
  for i := 0 to lvNotes.Items.Count - 1 do
  begin
    if TNote(lvNotes.Items[i].Data) = Note then
    begin
      lvNotes.ItemIndex := i;
      lvNotes.Items[i].Selected := True;
      Break;
    end;
  end;
  
  DisplayNote(Note);
  edtTitle.SetFocus;
  edtTitle.SelectAll;
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  SaveCurrentNote;
  FNoteManager.SaveData;
  LoadNoteList;
  UpdateStatusBar;
  ShowMessage('Not kaydedildi.');
end;

procedure TfrmMain.btnDeleteClick(Sender: TObject);
begin
  if not Assigned(FCurrentNote) then
    Exit;
    
  if MessageDlg('Bu notu silmek istediğinizden emin misiniz?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FNoteManager.DeleteNote(FCurrentNote.ID);
    LoadNoteList;
    ClearEditor;
    UpdateStatusBar;
  end;
end;

procedure TfrmMain.lvNotesSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected and Assigned(Item.Data) then
  begin
    SaveCurrentNote;
    DisplayNote(TNote(Item.Data));
  end;
end;

procedure TfrmMain.edtTitleChange(Sender: TObject);
begin
  if not FIsLoading then
  begin
    FNoteManager.Modified := True;
    UpdateStatusBar;
  end;
end;

procedure TfrmMain.memoContentChange(Sender: TObject);
begin
  if not FIsLoading then
  begin
    FNoteManager.Modified := True;
    UpdateStatusBar;
  end;
end;

procedure TfrmMain.edtSearchChange(Sender: TObject);
begin
  LoadNoteList;
end;

procedure TfrmMain.cmbCategoryChange(Sender: TObject);
begin
  LoadNoteList;
end;

procedure TfrmMain.mnuAddCategoryClick(Sender: TObject);
var
  CategoryName: string;
  CategoryColor: TColor;
begin
  CategoryName := '';
  CategoryColor := clBlue;
  if GetCategoryDialog(CategoryName, CategoryColor) then
  begin
    FNoteManager.AddCategory(CategoryName, CategoryColor);
    LoadCategories;
    UpdateStatusBar;
  end;
end;

procedure TfrmMain.mnuManageCategoriesClick(Sender: TObject);
begin
  if ShowCategoryManager(FNoteManager) then
  begin
    LoadCategories;
    LoadNoteList;
    UpdateStatusBar;
  end;
end;

procedure TfrmMain.mnuBackupClick(Sender: TObject);
begin
  SaveDialog1.Title := 'Yedek Dosya Kaydet';
  SaveDialog1.Filter := 'Şifreli Yedek Dosyası (*.bak)|*.bak';
  SaveDialog1.DefaultExt := 'bak';
  SaveDialog1.FileName := 'diary_backup_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.bak';
  
  if SaveDialog1.Execute then
  begin
    try
      SaveCurrentNote;
      FNoteManager.SaveData;
      FNoteManager.CreateBackup(SaveDialog1.FileName);
      ShowMessage('Yedek başarıyla oluşturuldu.');
    except
      on E: Exception do
        ShowMessage('Yedekleme hatası: ' + E.Message);
    end;
  end;
end;

procedure TfrmMain.mnuRestoreClick(Sender: TObject);
var
  Password: string;
begin
  if MessageDlg('Yedek geri yükleme mevcut verilerinizin kaybolmasına neden olabilir. Devam etmek istiyor musunuz?',
    mtWarning, [mbYes, mbNo], 0) = mrNo then
    Exit;
    
  OpenDialog1.Title := 'Yedek Dosya Seç';
  OpenDialog1.Filter := 'Şifreli Yedek Dosyası (*.bak)|*.bak|Tüm Dosyalar (*.*)|*.*';
  
  if OpenDialog1.Execute then
  begin
    if TfrmPassword.Execute('Yedek Dosya Şifresi', Password, False) then
    begin
      if FNoteManager.RestoreBackup(OpenDialog1.FileName, Password) then
      begin
        LoadCategories;
        LoadNoteList;
        ClearEditor;
        UpdateStatusBar;
        ShowMessage('Yedek başarıyla geri yüklendi.');
      end
      else
        ShowMessage('Yedek geri yüklenemedi. Şifre hatalı veya dosya bozuk olabilir.');
    end;
  end;
end;

procedure TfrmMain.mnuChangePasswordClick(Sender: TObject);
var
  OldPassword, NewPassword: string;
begin
  if TfrmPassword.Execute('Mevcut Şifre', OldPassword, False) then
  begin
    if OldPassword = FNoteManager.Password then
    begin
      if TfrmPassword.Execute('Yeni Şifre', NewPassword, True) then
      begin
        FNoteManager.Password := NewPassword;
        SaveCurrentNote;
        FNoteManager.SaveData;
        ShowMessage('Şifre başarıyla değiştirildi.');
      end;
    end
    else
      ShowMessage('Mevcut şifre hatalı!');
  end;
end;

procedure TfrmMain.mnuExitClick(Sender: TObject);
begin
  Close;
end;

end.