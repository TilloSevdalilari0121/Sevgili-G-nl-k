unit CategoryDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, DataModel;

type
  TfrmCategoryManager = class(TForm)
    Panel1: TPanel;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    btnClose: TButton;
    ListView1: TListView;
    ColorDialog1: TColorDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure ListView1CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure btnCloseClick(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
  private
    FNoteManager: TNoteManager;
    procedure LoadCategories;
  public
    property NoteManager: TNoteManager read FNoteManager write FNoteManager;
  end;

  // Basit kategori input dialog helper
  TCategoryDialogHelper = class
  public
    ColorDialog: TColorDialog;
    ColorPanel: TPanel;
    procedure OnColorButtonClick(Sender: TObject);
  end;

function ShowCategoryManager(ANoteManager: TNoteManager): Boolean;
function GetCategoryDialog(var CategoryName: string; var CategoryColor: TColor): Boolean;

implementation

{$R *.dfm}

procedure TCategoryDialogHelper.OnColorButtonClick(Sender: TObject);
begin
  ColorDialog.Color := ColorPanel.Color;
  if ColorDialog.Execute then
    ColorPanel.Color := ColorDialog.Color;
end;

function GetCategoryDialog(var CategoryName: string; var CategoryColor: TColor): Boolean;
var
  Dialog: TForm;
  lblName: TLabel;
  edtName: TEdit;
  pnlColor: TPanel;
  btnColor: TButton;
  btnOK, btnCancel: TButton;
  dlgColor: TColorDialog;
  Helper: TCategoryDialogHelper;
begin
  Result := False;
  Helper := TCategoryDialogHelper.Create;
  
  try
    Dialog := TForm.Create(nil);
    try
      Dialog.Caption := 'Kategori';
      Dialog.Width := 300;
      Dialog.Height := 200;
      Dialog.Position := poMainFormCenter;
      Dialog.BorderStyle := bsDialog;
      Dialog.FormStyle := fsStayOnTop;
      
      // İsim label
      lblName := TLabel.Create(Dialog);
      lblName.Parent := Dialog;
      lblName.Caption := 'Kategori Adı:';
      lblName.Left := 16;
      lblName.Top := 20;
      
      // İsim edit
      edtName := TEdit.Create(Dialog);
      edtName.Parent := Dialog;
      edtName.Left := 16;
      edtName.Top := 40;
      edtName.Width := 250;
      edtName.Text := CategoryName;
      
      // Renk paneli
      pnlColor := TPanel.Create(Dialog);
      pnlColor.Parent := Dialog;
      pnlColor.Left := 16;
      pnlColor.Top := 75;
      pnlColor.Width := 30;
      pnlColor.Height := 30;
      pnlColor.Color := CategoryColor;
      pnlColor.BevelOuter := bvRaised;
      
      // Color dialog
      dlgColor := TColorDialog.Create(Dialog);
      
      // Helper'ı ayarla
      Helper.ColorDialog := dlgColor;
      Helper.ColorPanel := pnlColor;
      
      // Renk butonu
      btnColor := TButton.Create(Dialog);
      btnColor.Parent := Dialog;
      btnColor.Caption := 'Renk Seç...';
      btnColor.Left := 56;
      btnColor.Top := 75;
      btnColor.Width := 75;
      btnColor.Height := 30;
      btnColor.OnClick := Helper.OnColorButtonClick;
      
      // OK butonu
      btnOK := TButton.Create(Dialog);
      btnOK.Parent := Dialog;
      btnOK.Caption := 'Tamam';
      btnOK.Left := 110;
      btnOK.Top := 125;
      btnOK.Width := 75;
      btnOK.ModalResult := mrOK;
      btnOK.Default := True;
      
      // Cancel butonu
      btnCancel := TButton.Create(Dialog);
      btnCancel.Parent := Dialog;
      btnCancel.Caption := 'İptal';
      btnCancel.Left := 191;
      btnCancel.Top := 125;
      btnCancel.Width := 75;
      btnCancel.ModalResult := mrCancel;
      btnCancel.Cancel := True;
      
      // Dialog göster
      if Dialog.ShowModal = mrOK then
      begin
        if Trim(edtName.Text) = '' then
        begin
          ShowMessage('Kategori adı boş olamaz!');
          Exit;
        end;
        CategoryName := edtName.Text;
        CategoryColor := pnlColor.Color;
        Result := True;
      end;
    finally
      Dialog.Free;
    end;
  finally
    Helper.Free;
  end;
end;

function ShowCategoryManager(ANoteManager: TNoteManager): Boolean;
var
  frm: TfrmCategoryManager;
begin
  frm := TfrmCategoryManager.Create(nil);
  try
    frm.NoteManager := ANoteManager;
    frm.LoadCategories;
    Result := frm.ShowModal = mrOK;
  finally
    frm.Free;
  end;
end;

procedure TfrmCategoryManager.FormCreate(Sender: TObject);
begin
  Position := poMainFormCenter;
  Caption := 'Kategori Yönetimi';
  
  ListView1.ViewStyle := vsReport;
  ListView1.RowSelect := True;
  ListView1.Color := clWindow;
  ListView1.Font.Color := clWindowText;
  ListView1.GridLines := True;
  
  with ListView1.Columns.Add do
  begin
    Caption := 'Kategori Adı';
    Width := 250;
  end;
  
  with ListView1.Columns.Add do
  begin
    Caption := 'Not Sayısı';
    Width := 80;
    Alignment := taRightJustify;
  end;
end;

procedure TfrmCategoryManager.LoadCategories;
var
  Category: TCategory;
  Item: TListItem;
  NoteCount: Integer;
  Note: TNote;
begin
  ListView1.Items.BeginUpdate;
  try
    ListView1.Clear;
    
    for Category in FNoteManager.Categories do
    begin
      Item := ListView1.Items.Add;
      Item.Caption := Category.Name;
      Item.Data := Category;
      
      NoteCount := 0;
      for Note in FNoteManager.Notes do
      begin
        if Note.CategoryID = Category.ID then
          Inc(NoteCount);
      end;
      
      Item.SubItems.Add(IntToStr(NoteCount));
    end;
  finally
    ListView1.Items.EndUpdate;
  end;
end;

procedure TfrmCategoryManager.btnAddClick(Sender: TObject);
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
  end;
end;

procedure TfrmCategoryManager.btnEditClick(Sender: TObject);
var
  CategoryName: string;
  CategoryColor: TColor;
  Category: TCategory;
begin
  if ListView1.Selected = nil then
  begin
    MessageDlg('Lütfen bir kategori seçin.', mtInformation, [mbOK], 0);
    Exit;
  end;
    
  Category := TCategory(ListView1.Selected.Data);
  CategoryName := Category.Name;
  CategoryColor := Category.Color;
  
  if GetCategoryDialog(CategoryName, CategoryColor) then
  begin
    Category.Name := CategoryName;
    Category.Color := CategoryColor;
    FNoteManager.Modified := True;
    LoadCategories;
  end;
end;

procedure TfrmCategoryManager.btnDeleteClick(Sender: TObject);
var
  Category: TCategory;
begin
  if ListView1.Selected = nil then
  begin
    MessageDlg('Lütfen bir kategori seçin.', mtInformation, [mbOK], 0);
    Exit;
  end;
    
  Category := TCategory(ListView1.Selected.Data);
  
  if ListView1.Selected.Index < 4 then
  begin
    MessageDlg('Varsayılan kategoriler silinemez!', mtError, [mbOK], 0);
    Exit;
  end;
  
  if MessageDlg(Format('"%s" kategorisini silmek istediğinizden emin misiniz?'#13#10 +
    'Bu kategorideki notlar "Genel" kategorisine taşınacaktır.',
    [Category.Name]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FNoteManager.DeleteCategory(Category.ID);
    LoadCategories;
  end;
end;

procedure TfrmCategoryManager.ListView1CustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
var
  Category: TCategory;
  Rect: TRect;
  ColorRect: TRect;
begin
  if not Assigned(Item.Data) then
    Exit;
    
  Category := TCategory(Item.Data);
  
  if cdsSelected in State then
  begin
    Sender.Canvas.Brush.Color := clHighlight;
    Sender.Canvas.Font.Color := clHighlightText;
  end
  else
  begin
    Sender.Canvas.Brush.Color := clWindow;
    Sender.Canvas.Font.Color := clWindowText;
  end;
  
  Rect := Item.DisplayRect(drBounds);
  Sender.Canvas.FillRect(Rect);
  
  ColorRect := Rect;
  ColorRect.Left := Rect.Left + 4;
  ColorRect.Right := ColorRect.Left + 16;
  ColorRect.Top := Rect.Top + 2;
  ColorRect.Bottom := Rect.Bottom - 2;
  
  Sender.Canvas.Brush.Color := Category.Color;
  Sender.Canvas.FillRect(ColorRect);
  Sender.Canvas.Brush.Color := clBlack;
  Sender.Canvas.FrameRect(ColorRect);
  
  Rect.Left := ColorRect.Right + 8;
  Sender.Canvas.Brush.Style := bsClear;
  DrawText(Sender.Canvas.Handle, PChar(Category.Name), -1, Rect,
    DT_SINGLELINE or DT_VCENTER or DT_LEFT);
    
  if Item.SubItems.Count > 0 then
  begin
    Rect := Item.DisplayRect(drBounds);
    Rect.Left := Rect.Left + ListView1.Columns[0].Width;
    Rect.Right := Rect.Left + ListView1.Columns[1].Width - 5;
    DrawText(Sender.Canvas.Handle, PChar(Item.SubItems[0]), -1, Rect,
      DT_SINGLELINE or DT_VCENTER or DT_RIGHT);
  end;
  
  DefaultDraw := False;
end;

procedure TfrmCategoryManager.btnCloseClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TfrmCategoryManager.ListView1DblClick(Sender: TObject);
begin
  btnEditClick(Sender);
end;

end.