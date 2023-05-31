unit TypeAddUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.Buttons, MainUnit, Vcl.CheckLst, Vcl.ComCtrls, PngImage, Jpeg;

type
  TAddTypeForm = class(TForm)
    TypeNameEdit: TLabeledEdit;
    CodeEdit: TLabeledEdit;
    AddBtn: TBitBtn;
    InfoLabel: TLabel;
    ChangeBtn: TBitBtn;
    Image1: TImage;
    procedure StrKeyPress(Sender: TObject; var Key: Char);
    procedure LabeledEditChange(Sender: TObject);
    procedure NumberPress(Sender: TObject; var Key: Char);
    procedure LabeledEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AddBtnClick(Sender: TObject);
    Procedure ClearEdits;
    Function NormalizeString(const AStr: String): String;
    procedure ChangeBtnClick(Sender: TObject);
    Procedure SetCandyFields(Temp: PCandyType);
    Procedure SetCandyEdits(Temp: PCandyType);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    Function IsSimilarCandyType(Head, Temp: PCandyType): Boolean;
    Function WasNotChanged(Temp: PCandyType): Boolean;
    procedure CodeEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Image1Click(Sender: TObject);
  private
      FCurrentPointer: PCandyType;
  public
  end;

var
    AddTypeForm: TAddTypeForm;

implementation

{$R *.dfm}

procedure TAddTypeForm.NumberPress(Sender: TObject; var Key: Char);
Var
    CursorPosition, NewCursorPosition: Integer;
    TempAll, TempSelected, TempBeforeCursor, TempAfterCursor: String;
begin
    If Not(Key In ['0'..'9', #08]) Then
        Key := #0;
    NewCursorPosition := Length(TEdit(Sender).Text) - Length(TEdit(Sender).SelText);
    TempSelected := TEdit(Sender).SelText;
    TempAll := TEdit(Sender).Text;
    CursorPosition := TEdit(Sender).SelStart;
    If (TEdit(Sender).SelStart = 0) and (TEdit(Sender).SelLength < TEdit(Sender).GetTextLen) and (Key = '0') Then
        Key := #0;
    If (Key <> #0) and (TempSelected <> '') Then
        Begin
            Try
                Delete(TempAll, CursorPosition + 1, Length(TempSelected));
                Insert(Key, TempAll, CursorPosition + 1);
                If (StrToInt(TempAll) < 1) or (StrToInt(TempAll) > 9999) Then
                  Key := #0
                Else
                    Begin
                        TEdit(Sender).Text := TempAll;
                        TEdit(Sender).SelStart := NewCursorPosition + 1;
                        Key := #0;
                    End;
            Except
                Key := #0;
            End;
        End;
    TempBeforeCursor := Copy(TEdit(Sender).Text, 1, TEdit(Sender).SelStart);
    TempAfterCursor := Copy(TEdit(Sender).Text, TEdit(Sender).SelStart + 1, TEdit(Sender).GetTextLen);
    If (Key <> #0) and (Key <> #08) and ((StrToInt(TempBeforeCursor + Key + TempAfterCursor) < 1) or (StrToInt(TempBeforeCursor + Key + TempAfterCursor) > 9999)) Then
        Key := #0;
end;

procedure TAddTypeForm.LabeledEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    If (Shift = [ssCtrl]) and (Key = Ord('A')) then
        TLabeledEdit(Sender).SelectAll;
end;

Function TAddTypeForm.WasNotChanged(Temp: PCandyType): Boolean;
Begin
    WasNotChanged := (FCurrentPointer.Info.Code = Temp.Info.Code) and
    (FCurrentPointer.Info.TypeOfCandy = Temp.Info.TypeOfCandy);
End;

procedure TAddTypeForm.ChangeBtnClick(Sender: TObject);
Var
    Temp: PCandyType;
begin
    New(Temp);
    SetCandyFields(Temp);
    Temp^.Next := Nil;
    If WasNotChanged(Temp) Then
    Begin
        SetCandyFields(FCurrentPointer);
        Self.Close;
        ModalResult := mrYes;
        Dispose(Temp);
    End
    Else If IsSimilarCandyType(FCurrentPointer, Temp) Then
        Application.MessageBox('������ ��� �������� ��� ���� � ������!', '������', MB_ICONERROR)
    Else
    Begin
        SetCandyFields(FCurrentPointer);
        Self.Close;
        ModalResult := mrYes;
        Dispose(Temp);
    End;
end;

Procedure TAddTypeForm.SetCandyEdits(Temp: PCandyType);
Begin
    FCurrentPointer := Temp;
    TypeNameEdit.Text := Temp^.Info.TypeOfCandy;
    CodeEdit.Text := IntToStr(Temp^.Info.Code);
End;

Procedure TAddTypeForm.SetCandyFields(Temp: PCandyType);
Begin
    Temp^.Info.TypeOfCandy := NormalizeString(TypeNameEdit.Text);
    Temp^.Info.Code := StrToInt(CodeEdit.Text);
    Temp.Info.CandyItself := Nil;
End;

procedure TAddTypeForm.ClearEdits;
Begin
    TypeNameEdit.Clear;
    CodeEdit.Clear;
End;

procedure TAddTypeForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    ClearEdits;
end;

Function TAddTypeForm.NormalizeString(const AStr: String): String;
Var
    LowerStr, RestOfString: String;
    FirstLetter: String[1];
Begin
    LowerStr := AnsiLowerCase(AStr);
    FirstLetter := AnsiUpperCase(Copy(LowerStr, 1, 1));
    RestOfString := Copy(LowerStr, 2, Length(LowerStr) - 1);
    NormalizeString := FirstLetter + RestOfString;
End;

procedure TAddTypeForm.Image1Click(Sender: TObject);
begin
    ClearEdits;
end;

Function TAddTypeForm.IsSimilarCandyType(Head, Temp: PCandyType): Boolean;
Var
    IsCorrect: Boolean;
    Current: PCandyType;
Begin
    Current := Head;
    IsCorrect := False;
    While Not(IsCorrect) and (Current <> Nil) do
    Begin
        IsCorrect := (Current^.Info.Code = Temp^.Info.Code) or
        (Current^.Info.TypeOfCandy = Temp^.Info.TypeOfCandy);
        Current := Current^.Next;
    End;
    IsSimilarCandyType := IsCorrect;
End;

procedure TAddTypeForm.AddBtnClick(Sender: TObject);
Var
    Temp: PCandyType;
begin
    New(Temp);
    SetCandyFields(Temp);
    Temp^.Next := Nil;
    If IsSimilarCandyType(MainForm.CandyList.Head, Temp) Then
        Application.MessageBox('������ ��� �������� ��� ���� � ������!', '������', MB_ICONERROR)
    Else
    Begin
        MainForm.InsertInList(Temp^);
        Self.Close;
        ModalResult := mrYes;
    End;
    Dispose(Temp);
end;

procedure TAddTypeForm.LabeledEditChange(Sender: TObject);
Var
    I: Integer;
begin
    AddBtn.Enabled := (TypeNameEdit.GetTextLen > 0) and (CodeEdit.GetTextLen > 0);
    ChangeBtn.Enabled := (TypeNameEdit.GetTextLen > 0) and (CodeEdit.GetTextLen > 0);
    If (TLabeledEdit(Sender).GetTextLen > 0) and (TLabeledEdit(Sender).Text[1] = '0') then
    begin
        I := 1;
        While TLabeledEdit(Sender).Text[I] = '0' do
            Inc(I);
        TLabeledEdit(Sender).Text := Copy(TLabeledEdit(Sender).Text, I, TLabeledEdit(Sender).GetTextLen - I + 1);
    end;
end;

procedure TAddTypeForm.StrKeyPress(Sender: TObject; var Key: Char);
begin
    If (TEdit(Sender).SelLength > 0) and Not((Key < #192) and (Key <> #08)) Then
        TEdit(Sender).SelText := #0;
    If (Key < #192) and (Key <> #08) Then
        Key := #0;
    If (Key = '�') Then
        Key := #0;
    If (Length(TEdit(Sender).Text) = 15) and (Key <> #08) Then
        Key := #0;
end;

procedure TAddTypeForm.CodeEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    If (Shift = [ssCtrl]) and (Key = Ord('A')) then
        TLabeledEdit(Sender).SelectAll;
    TEdit(Sender).ReadOnly := (((Shift=[ssShift]) and (Key = VK_INSERT)) or (Shift=[ssCtrl]) or (Shift=[ssAlt]));
end;

end.
