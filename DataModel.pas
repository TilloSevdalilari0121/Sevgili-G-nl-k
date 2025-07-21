unit DataModel;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Vcl.ExtCtrls,
  System.DateUtils;

type
  TCategory = class
  private
    FID: string;
    FName: string;
    FColor: Integer;
  public
    property ID: string read FID write FID;
    property Name: string read FName write FName;
    property Color: Integer read FColor write FColor;
    constructor Create(const AName: string; AColor: Integer = 0);
  end;

  TNote = class
  private
    FID: string;
    FTitle: string;
    FContent: string;
    FCreatedDate: TDateTime;
    FModifiedDate: TDateTime;
    FCategoryID: string;
    FTags: TStringList;
  public
    property ID: string read FID write FID;
    property Title: string read FTitle write FTitle;
    property Content: string read FContent write FContent;
    property CreatedDate: TDateTime read FCreatedDate write FCreatedDate;
    property ModifiedDate: TDateTime read FModifiedDate write FModifiedDate;
    property CategoryID: string read FCategoryID write FCategoryID;
    property Tags: TStringList read FTags;
    
    constructor Create;
    destructor Destroy; override;
    procedure UpdateModifiedDate;
  end;

  TNoteManager = class
  private
    FNotes: TObjectList<TNote>;
    FCategories: TObjectList<TCategory>;
    FPassword: string;
    FDataFile: string;
    FAutoSaveTimer: TTimer;
    FModified: Boolean;
    
    procedure OnAutoSaveTimer(Sender: TObject);
  public
    property Notes: TObjectList<TNote> read FNotes;
    property Categories: TObjectList<TCategory> read FCategories;
    property Modified: Boolean read FModified write FModified;
    property Password: string read FPassword write FPassword;
    property AutoSaveTimer: TTimer read FAutoSaveTimer;
    
    constructor Create(const ADataFile: string);
    destructor Destroy; override;
    
    function LoadData(const APassword: string): Boolean;
    procedure SaveData;
    procedure EnableAutoSave(IntervalSeconds: Integer = 300);
    procedure DisableAutoSave;
    
    function AddNote(const ATitle, AContent, ACategoryID: string): TNote;
    procedure UpdateNote(ANote: TNote);
    procedure DeleteNote(const ANoteID: string);
    function FindNote(const ANoteID: string): TNote;
    function SearchNotes(const ASearchText: string): TList<TNote>;
    
    function AddCategory(const AName: string; AColor: Integer): TCategory;
    procedure DeleteCategory(const ACategoryID: string);
    function GetNotesByCategory(const ACategoryID: string): TList<TNote>;
    
    procedure CreateBackup(const ABackupFile: string);
    function RestoreBackup(const ABackupFile, APassword: string): Boolean;
  end;

implementation

uses
  System.JSON, System.IOUtils, EncryptionUnit;

{ TCategory }

constructor TCategory.Create(const AName: string; AColor: Integer);
begin
  FID := TGUID.NewGuid.ToString;
  FName := AName;
  FColor := AColor;
end;

{ TNote }

constructor TNote.Create;
begin
  FID := TGUID.NewGuid.ToString;
  FCreatedDate := Now;
  FModifiedDate := Now;
  FTags := TStringList.Create;
  FTags.Delimiter := ',';
  FTags.StrictDelimiter := True;
end;

destructor TNote.Destroy;
begin
  FTags.Free;
  inherited;
end;

procedure TNote.UpdateModifiedDate;
begin
  FModifiedDate := Now;
end;

{ TNoteManager }

constructor TNoteManager.Create(const ADataFile: string);
begin
  FDataFile := ADataFile;
  FNotes := TObjectList<TNote>.Create(True);
  FCategories := TObjectList<TCategory>.Create(True);
  FAutoSaveTimer := TTimer.Create(nil);
  FAutoSaveTimer.Enabled := False;
  FAutoSaveTimer.OnTimer := OnAutoSaveTimer;
  
  // Varsayılan kategoriler
  AddCategory('Genel', $00FF00);
  AddCategory('Kişisel', $FF0000);
  AddCategory('İş', $0000FF);
  AddCategory('Fikirler', $FF00FF);
  AddCategory('Sağlık', $FF00FF);
  AddCategory('Dini', $FF00FF);
  AddCategory('BlockChain', $FF00FF);
end;

destructor TNoteManager.Destroy;
begin
  DisableAutoSave;
  FAutoSaveTimer.Free;
  FNotes.Free;
  FCategories.Free;
  inherited;
end;

function TNoteManager.LoadData(const APassword: string): Boolean;
var
  EncryptedData, DecryptedData: string;
  JSONData: TJSONObject;
  NotesArray, CategoriesArray: TJSONArray;
  NoteObj, CategoryObj: TJSONObject;
  Note: TNote;
  Category: TCategory;
  i: Integer;
  TempValue: TJSONValue;
begin
  Result := False;
  FPassword := APassword;
  
  if not FileExists(FDataFile) then
  begin
    Result := True;
    Exit;
  end;
  
  try
    EncryptedData := TFile.ReadAllText(FDataFile, TEncoding.UTF8);
    DecryptedData := TEncryption.Decrypt(EncryptedData, FPassword);
    
    if DecryptedData = '' then
      Exit;
    
    JSONData := TJSONObject.ParseJSONValue(DecryptedData) as TJSONObject;
    if not Assigned(JSONData) then
      Exit;
      
    try
      FCategories.Clear;
      TempValue := JSONData.GetValue('categories');
      if Assigned(TempValue) and (TempValue is TJSONArray) then
      begin
        CategoriesArray := TempValue as TJSONArray;
        for i := 0 to CategoriesArray.Count - 1 do
        begin
          CategoryObj := CategoriesArray.Items[i] as TJSONObject;
          Category := TCategory.Create('', 0);
          Category.ID := CategoryObj.GetValue('id').Value;
          Category.Name := CategoryObj.GetValue('name').Value;
          Category.Color := StrToIntDef(CategoryObj.GetValue('color').Value, 0);
          FCategories.Add(Category);
        end;
      end;
      
      FNotes.Clear;
      TempValue := JSONData.GetValue('notes');
      if Assigned(TempValue) and (TempValue is TJSONArray) then
      begin
        NotesArray := TempValue as TJSONArray;
        for i := 0 to NotesArray.Count - 1 do
        begin
          NoteObj := NotesArray.Items[i] as TJSONObject;
          Note := TNote.Create;
          Note.ID := NoteObj.GetValue('id').Value;
          Note.Title := NoteObj.GetValue('title').Value;
          Note.Content := NoteObj.GetValue('content').Value;
          Note.CreatedDate := ISO8601ToDate(NoteObj.GetValue('created').Value);
          Note.ModifiedDate := ISO8601ToDate(NoteObj.GetValue('modified').Value);
          
          TempValue := NoteObj.GetValue('categoryId');
          if Assigned(TempValue) then
            Note.CategoryID := TempValue.Value;
            
          TempValue := NoteObj.GetValue('tags');
          if Assigned(TempValue) then
            Note.Tags.DelimitedText := TempValue.Value;
            
          FNotes.Add(Note);
        end;
      end;
      
      Result := True;
    finally
      JSONData.Free;
    end;
  except
    on E: Exception do
      Result := False;
  end;
end;

procedure TNoteManager.SaveData;
var
  JSONData: TJSONObject;
  NotesArray, CategoriesArray: TJSONArray;
  NoteObj, CategoryObj: TJSONObject;
  PlainText, EncryptedText: string;
  i: Integer;
begin
  JSONData := TJSONObject.Create;
  try
    CategoriesArray := TJSONArray.Create;
    for i := 0 to FCategories.Count - 1 do
    begin
      CategoryObj := TJSONObject.Create;
      CategoryObj.AddPair('id', FCategories[i].ID);
      CategoryObj.AddPair('name', FCategories[i].Name);
      CategoryObj.AddPair('color', IntToStr(FCategories[i].Color));
      CategoriesArray.Add(CategoryObj);
    end;
    JSONData.AddPair('categories', CategoriesArray);
    
    NotesArray := TJSONArray.Create;
    for i := 0 to FNotes.Count - 1 do
    begin
      NoteObj := TJSONObject.Create;
      NoteObj.AddPair('id', FNotes[i].ID);
      NoteObj.AddPair('title', FNotes[i].Title);
      NoteObj.AddPair('content', FNotes[i].Content);
      NoteObj.AddPair('created', DateToISO8601(FNotes[i].CreatedDate));
      NoteObj.AddPair('modified', DateToISO8601(FNotes[i].ModifiedDate));
      NoteObj.AddPair('categoryId', FNotes[i].CategoryID);
      NoteObj.AddPair('tags', FNotes[i].Tags.DelimitedText);
      NotesArray.Add(NoteObj);
    end;
    JSONData.AddPair('notes', NotesArray);
    
    JSONData.AddPair('version', '1.0');
    JSONData.AddPair('lastSaved', DateToISO8601(Now));
    
    PlainText := JSONData.ToString;
    EncryptedText := TEncryption.Encrypt(PlainText, FPassword);
    TFile.WriteAllText(FDataFile, EncryptedText, TEncoding.UTF8);
    
    FModified := False;
  finally
    JSONData.Free;
  end;
end;

procedure TNoteManager.EnableAutoSave(IntervalSeconds: Integer);
begin
  FAutoSaveTimer.Interval := IntervalSeconds * 1000;
  FAutoSaveTimer.Enabled := True;
end;

procedure TNoteManager.DisableAutoSave;
begin
  FAutoSaveTimer.Enabled := False;
end;

procedure TNoteManager.OnAutoSaveTimer(Sender: TObject);
begin
  if FModified then
    SaveData;
end;

function TNoteManager.AddNote(const ATitle, AContent, ACategoryID: string): TNote;
begin
  Result := TNote.Create;
  Result.Title := ATitle;
  Result.Content := AContent;
  Result.CategoryID := ACategoryID;
  FNotes.Add(Result);
  FModified := True;
end;

procedure TNoteManager.UpdateNote(ANote: TNote);
begin
  if Assigned(ANote) then
  begin
    ANote.UpdateModifiedDate;
    FModified := True;
  end;
end;

procedure TNoteManager.DeleteNote(const ANoteID: string);
var
  i: Integer;
begin
  for i := FNotes.Count - 1 downto 0 do
  begin
    if FNotes[i].ID = ANoteID then
    begin
      FNotes.Delete(i);
      FModified := True;
      Break;
    end;
  end;
end;

function TNoteManager.FindNote(const ANoteID: string): TNote;
var
  Note: TNote;
begin
  Result := nil;
  for Note in FNotes do
  begin
    if Note.ID = ANoteID then
    begin
      Result := Note;
      Break;
    end;
  end;
end;

function TNoteManager.SearchNotes(const ASearchText: string): TList<TNote>;
var
  Note: TNote;
  SearchLower: string;
begin
  Result := TList<TNote>.Create;
  SearchLower := LowerCase(ASearchText);
  
  for Note in FNotes do
  begin
    if (Pos(SearchLower, LowerCase(Note.Title)) > 0) or
       (Pos(SearchLower, LowerCase(Note.Content)) > 0) or
       (Pos(SearchLower, LowerCase(Note.Tags.DelimitedText)) > 0) then
      Result.Add(Note);
  end;
end;

function TNoteManager.AddCategory(const AName: string; AColor: Integer): TCategory;
begin
  Result := TCategory.Create(AName, AColor);
  FCategories.Add(Result);
  FModified := True;
end;

procedure TNoteManager.DeleteCategory(const ACategoryID: string);
var
  i: Integer;
  Note: TNote;
begin
  for Note in FNotes do
  begin
    if Note.CategoryID = ACategoryID then
      Note.CategoryID := FCategories[0].ID;
  end;
  
  for i := FCategories.Count - 1 downto 0 do
  begin
    if FCategories[i].ID = ACategoryID then
    begin
      FCategories.Delete(i);
      FModified := True;
      Break;
    end;
  end;
end;

function TNoteManager.GetNotesByCategory(const ACategoryID: string): TList<TNote>;
var
  Note: TNote;
begin
  Result := TList<TNote>.Create;
  for Note in FNotes do
  begin
    if Note.CategoryID = ACategoryID then
      Result.Add(Note);
  end;
end;

procedure TNoteManager.CreateBackup(const ABackupFile: string);
begin
  if FileExists(FDataFile) then
    TFile.Copy(FDataFile, ABackupFile, True);
end;

function TNoteManager.RestoreBackup(const ABackupFile, APassword: string): Boolean;
var
  TempFile: string;
begin
  Result := False;
  if not FileExists(ABackupFile) then
    Exit;
    
  TempFile := FDataFile + '.tmp';
  try
    if FileExists(FDataFile) then
      TFile.Move(FDataFile, TempFile);
      
    TFile.Copy(ABackupFile, FDataFile, True);
    
    Result := LoadData(APassword);
    
    if Result then
    begin
      if FileExists(TempFile) then
        TFile.Delete(TempFile);
    end
    else
    begin
      if FileExists(TempFile) then
      begin
        TFile.Delete(FDataFile);
        TFile.Move(TempFile, FDataFile);
      end;
    end;
  except
    if FileExists(TempFile) then
    begin
      if FileExists(FDataFile) then
        TFile.Delete(FDataFile);
      TFile.Move(TempFile, FDataFile);
    end;
    Result := False;
  end;
end;

end.