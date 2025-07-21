unit EncryptionUnit;

interface

uses
  System.SysUtils, System.Classes, System.NetEncoding;

type
  TEncryption = class
  private
    class function SimpleHash(const Data: TBytes): TBytes;
    class function GenerateKey(const Password: string; Salt: TBytes): TBytes;
    class function GenerateSalt: TBytes;
    class function PKCS7Padding(const Data: TBytes; BlockSize: Integer): TBytes;
    class function RemovePKCS7Padding(const Data: TBytes): TBytes;
  public
    class function Encrypt(const PlainText: string; const Password: string): string;
    class function Decrypt(const CipherText: string; const Password: string): string;
  end;

implementation

uses
  System.Math;

class function TEncryption.SimpleHash(const Data: TBytes): TBytes;
var
  i, j: Integer;
  Hash: array[0..31] of Byte;
  Temp: UInt32;
begin
  // Basit ama etkili hash fonksiyonu
  for i := 0 to 31 do
    Hash[i] := i * 37;
    
  for i := 0 to Length(Data) - 1 do
  begin
    for j := 0 to 31 do
    begin
      Temp := (Hash[j] + Data[i] + i) * 1103515245 + 12345;
      Hash[j] := (Temp shr 16) and $FF;
    end;
  end;
  
  // Daha fazla karıştırma
  for i := 0 to 255 do
  begin
    for j := 0 to 31 do
    begin
      Temp := Hash[j] + Hash[(j + 1) mod 32];
      Hash[j] := ((Temp * 69069 + 1) shr 8) and $FF;
    end;
  end;
  
  SetLength(Result, 32);
  Move(Hash[0], Result[0], 32);
end;

class function TEncryption.GenerateKey(const Password: string; Salt: TBytes): TBytes;
var
  i: Integer;
  TempData: TBytes;
  PasswordBytes: TBytes;
begin
  PasswordBytes := TEncoding.UTF8.GetBytes(Password);
  TempData := PasswordBytes + Salt;
  Result := SimpleHash(TempData);
  
  // PBKDF2 benzeri iterasyon
  for i := 1 to 1000 do
  begin
    TempData := Result + Salt;
    Result := SimpleHash(TempData);
  end;
end;

class function TEncryption.GenerateSalt: TBytes;
var
  i: Integer;
begin
  SetLength(Result, 16);
  for i := 0 to 15 do
    Result[i] := Random(256);
end;

class function TEncryption.PKCS7Padding(const Data: TBytes; BlockSize: Integer): TBytes;
var
  PadLen: Integer;
  i: Integer;
begin
  if Length(Data) = 0 then
  begin
    SetLength(Result, BlockSize);
    for i := 0 to BlockSize - 1 do
      Result[i] := BlockSize;
    Exit;
  end;
  
  PadLen := BlockSize - (Length(Data) mod BlockSize);
  SetLength(Result, Length(Data) + PadLen);
  
  if Length(Data) > 0 then
    Move(Data[0], Result[0], Length(Data));
    
  for i := Length(Data) to Length(Result) - 1 do
    Result[i] := PadLen;
end;

class function TEncryption.RemovePKCS7Padding(const Data: TBytes): TBytes;
var
  PadLen: Integer;
begin
  if Length(Data) = 0 then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  
  PadLen := Data[Length(Data) - 1];
  if (PadLen > 0) and (PadLen <= Length(Data)) and (PadLen <= 16) then
  begin
    SetLength(Result, Length(Data) - PadLen);
    if Length(Result) > 0 then
      Move(Data[0], Result[0], Length(Result));
  end
  else
    Result := Copy(Data, 0, Length(Data));
end;

class function TEncryption.Encrypt(const PlainText: string; const Password: string): string;
var
  Salt, Key, IV: TBytes;
  PlainBytes, EncryptedBytes: TBytes;
  i, j: Integer;
  Block, PrevBlock: TBytes;
  FullData: TBytes;
  KeyIndex: Integer;
begin
  Salt := GenerateSalt;
  Key := GenerateKey(Password, Salt);
  
  SetLength(IV, 16);
  for i := 0 to 15 do
    IV[i] := Key[i mod Length(Key)] xor Salt[i];
  
  PlainBytes := TEncoding.UTF8.GetBytes(PlainText);
  PlainBytes := PKCS7Padding(PlainBytes, 16);
  
  SetLength(EncryptedBytes, Length(PlainBytes));
  SetLength(Block, 16);
  SetLength(PrevBlock, 16);
  
  Move(IV[0], PrevBlock[0], 16);
  
  for i := 0 to (Length(PlainBytes) div 16) - 1 do
  begin
    Move(PlainBytes[i * 16], Block[0], 16);
    
    for j := 0 to 15 do
      Block[j] := Block[j] xor PrevBlock[j];
    
    for j := 0 to 15 do
    begin
      KeyIndex := j mod Length(Key);
      Block[j] := Block[j] xor Key[KeyIndex];
      Block[j] := (Block[j] + Key[(KeyIndex + 16) mod Length(Key)]) mod 256;
      KeyIndex := (j + i) mod Length(Key);
      Block[j] := Block[j] xor Key[KeyIndex];
    end;
    
    Move(Block[0], EncryptedBytes[i * 16], 16);
    Move(Block[0], PrevBlock[0], 16);
  end;
  
  SetLength(FullData, 16 + Length(EncryptedBytes));
  Move(Salt[0], FullData[0], 16);
  if Length(EncryptedBytes) > 0 then
    Move(EncryptedBytes[0], FullData[16], Length(EncryptedBytes));
  
  Result := TNetEncoding.Base64.EncodeBytesToString(FullData);
end;

class function TEncryption.Decrypt(const CipherText: string; const Password: string): string;
var
  FullData, Salt, Key, IV: TBytes;
  EncryptedBytes, DecryptedBytes: TBytes;
  i, j: Integer;
  Block, TempBlock: TBytes;
  KeyIndex: Integer;
begin
  Result := '';
  try
    try
      FullData := TNetEncoding.Base64.DecodeStringToBytes(CipherText);
    except
      Exit;
    end;
    
    if Length(FullData) < 32 then
      Exit;
    
    SetLength(Salt, 16);
    Move(FullData[0], Salt[0], 16);
    
    SetLength(EncryptedBytes, Length(FullData) - 16);
    if Length(EncryptedBytes) > 0 then
      Move(FullData[16], EncryptedBytes[0], Length(EncryptedBytes));
    
    Key := GenerateKey(Password, Salt);
    
    SetLength(IV, 16);
    for i := 0 to 15 do
      IV[i] := Key[i mod Length(Key)] xor Salt[i];
    
    SetLength(DecryptedBytes, Length(EncryptedBytes));
    SetLength(Block, 16);
    SetLength(TempBlock, 16);
    
    for i := 0 to (Length(EncryptedBytes) div 16) - 1 do
    begin
      Move(EncryptedBytes[i * 16], Block[0], 16);
      
      for j := 0 to 15 do
      begin
        KeyIndex := (j + i) mod Length(Key);
        Block[j] := Block[j] xor Key[KeyIndex];
        KeyIndex := j mod Length(Key);
        Block[j] := (Block[j] - Key[(KeyIndex + 16) mod Length(Key)] + 256) mod 256;
        Block[j] := Block[j] xor Key[KeyIndex];
      end;
      
      if i = 0 then
      begin
        for j := 0 to 15 do
          Block[j] := Block[j] xor IV[j];
      end
      else
      begin
        Move(EncryptedBytes[(i - 1) * 16], TempBlock[0], 16);
        for j := 0 to 15 do
          Block[j] := Block[j] xor TempBlock[j];
      end;
      
      Move(Block[0], DecryptedBytes[i * 16], 16);
    end;
    
    DecryptedBytes := RemovePKCS7Padding(DecryptedBytes);
    
    if Length(DecryptedBytes) > 0 then
      Result := TEncoding.UTF8.GetString(DecryptedBytes);
  except
    on E: Exception do
      Result := '';
  end;
end;

initialization
  Randomize;

end.