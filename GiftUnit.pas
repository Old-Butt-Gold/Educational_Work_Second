unit GiftUnit;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, MainUnit, Vcl.ComCtrls, Vcl.Grids, CommCtrl,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.Menus;
type

  PGift = ^TGift;
  TGift = Record
      TypeofCandy, Name: String[15];
      Count, Sugar: Integer;
      Next: PGift;
  End;
  TArrayGift = Array of PGift;
  TArrOI = Array of Integer;
  
  TGiftForm = class(TForm)
    WeightEdit: TLabeledEdit;
    CountTypeEdit: TLabeledEdit;
    ValueEdit: TLabeledEdit;
    AddGiftBtn: TBitBtn;
    SaveTextFile: TSaveDialog;
    MainMenu: TMainMenu;
    N1: TMenuItem;
    TreeView1: TTreeView;
    procedure WeightEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure WeightEditKeyPress(Sender: TObject; var Key: Char);
    procedure WeightEditChange(Sender: TObject);
    Procedure CopyList(List: PCandyType);
    procedure AddGiftBtnClick(Sender: TObject);
    Function GetCountInList: Integer;
    Procedure ClearList;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    Procedure QSort(FSugarCountArray: TArrOI; Left, Right: Integer);
    Function Partition(FSugarCountArray: TArrOI; Left, Right: Integer): Integer;
    Procedure Swap(Var FSugarCountArray: TArrOI; I, J: Integer);
    procedure N1Click(Sender: TObject);
  private
      FCopyList: TTotalCandyType;
      FArr: TArrayGift;
      FCurrentCount: Integer;
  public

  end;
var
  GiftForm: TGiftForm;
implementation

procedure TGiftForm.CopyList(List: PCandyType);
var
    CurrentNode, NewNode: PCandyType;
    SecondList, SecondNode, LastNode: PCandy;
begin
    CurrentNode := List;
    While CurrentNode <> Nil do
    begin
        New(NewNode);
        NewNode^.Info := CurrentNode^.Info;
        NewNode^.Next := Nil;
        NewNode^.Info.CandyItself := Nil;
        SecondList := CurrentNode^.Info.CandyItself;
        LastNode := Nil;
        While SecondList <> Nil do
        Begin
            New(SecondNode);
            SecondNode^ := SecondList^;
            SecondNode.Next := Nil;

            If NewNode^.Info.CandyItself = Nil Then
                NewNode^.Info.CandyItself := SecondNode
            Else
                LastNode^.Next := SecondNode;
            LastNode := SecondNode;        
            SecondList := SecondList^.Next;
        End;
        If FCopyList.Tail = Nil then
            FCopyList.Head := NewNode
        Else
            FCopyList.Tail^.Next := NewNode;
        FCopyList.Tail := NewNode;
        CurrentNode := CurrentNode^.Next;
    end;
end;

Procedure TGiftForm.WeightEditKeyPress(Sender: TObject; var Key: Char);
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
End;
Function TGiftForm.GetCountInList: Integer;
Var
    I: Integer;
    Head: PCandyType;
Begin
    Head := FCopyList.Head;
    I := 0;
    While Head <> Nil do
    Begin
        Inc(I);
        Head := Head^.Next;
    End;
    GetCountInList := I;
End;

procedure TGiftForm.N1Click(Sender: TObject);
Var
    FileOutput: TextFile;
    I: Integer;
    Temp: PGift;
    Str: String;
begin
    If SaveTextFile.Execute Then
    Begin
        Try
            Try
                AssignFile(FileOutput, ChangeFileExt(SaveTextFile.FileName, '.txt'));
                Rewrite(FileOutput);
                For I := Low(FArr) to High(FArr) do
                Begin
                    Temp := FArr[I];
                    Str := '������� ' + IntToStr(I + 1) + ': ';
                    While Temp <> Nil do
                    Begin    
                        Str := Str + '��� ��������: ' + Temp.TypeofCandy + ' ' + '��� ��������: ' + Temp.Name + ' ' + '����������: ' + IntToStr(Temp.Count) + ' ' + '���������� ������: ' + IntToStr(Temp.Sugar) + '��. ; ';
                        Temp := Temp^.Next;
                    End;
                    Writeln(FileOutput, Str);
                End;
            Except
                MessageBox(Handle, '���� �����������!', '��������!', MB_OK + MB_ICONWARNING);
            End;
        Finally
            If FileExists(ChangeFileExt(SaveTextFile.FileName, '.txt')) Then
                CloseFile(FileOutput);
        End;
    End;
end;

Procedure TGiftForm.ClearList;
Var
    Head, NextNode: PCandyType;
    I: Integer;
Begin
    FArr := Nil;
    I := 0;
    Head := FCopyList.Head;
    while (I < FCurrentCount) and (Head <> nil) do
    begin
        NextNode := Head^.Next;
        Dispose(Head);
        Head := NextNode;
        Inc(I);
    end;
    FCopyList.Head := Nil;
    FCopyList.Tail := Nil;
End;

procedure TGiftForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    ClearList;
    ValueEdit.Clear;
    WeightEdit.Clear;
    CountTypeEdit.Clear;
    TreeView1.Items.Clear;
end;

Procedure TGiftForm.Swap(Var FSugarCountArray: TArrOI; I, J: Integer);
Var
    TempSugar: Integer;
    TempLinkedArray: PGift;
Begin
    TempSugar := FSugarCountArray[I];
    FSugarCountArray[I] := FSugarCountArray[J];
    FSugarCountArray[J] := TempSugar;

    TempLinkedArray := FArr[I];
    FArr[I] := FArr[J];
    FArr[J] := TempLinkedArray;        
End;

Function TGiftForm.Partition(FSugarCountArray: TArrOI; Left, Right: Integer): Integer;
Var
    Temp: Integer;
    I, J: Integer;
Begin
    Temp := FSugarCountArray[Left];
    I := Left;
    For J := I + 1 to Right do
    Begin       
        If FSugarCountArray[J] <= Temp Then
        Begin
            Inc(I);
            Swap(FSugarCountArray, I, J);
        End;
    End;
    Swap(FSugarCountArray, Left, I);
    Partition := I;
End;

Procedure TGiftForm.QSort(FSugarCountArray: TArrOI; Left, Right: Integer);
Var
    Temp: Integer;
Begin
    While Left < Right do
    Begin   
        Temp := Partition(FSugarCountArray, Left, Right);
        QSort(FSugarCountArray, Left, Temp - 1);
        Left := Temp + 1;    
    End;
End;

procedure TGiftForm.AddGiftBtnClick(Sender: TObject);
Var
    Head: PCandyType;
    CountType, TotalWeight, TotalValue: Integer;
    IsNotFilled: Boolean;
    Current: PCandy;
    LastNode, NewNode: PGift;
    I, TempWeight, TempValue: Integer;
    Temp: PGift;
    Index, ColIndex: Integer;
    FSugarCountArray: TArrOI;
    Item, GiftNode: TTreeNode;
begin
    ClearList;
    CopyList(MainForm.CandyList.Head);
    FCurrentCount := GetCountInList;
    IsNotFilled := True;
    If StrToInt(CountTypeEdit.Text) > FCurrentCount Then
        MessageBox(MainForm.Handle, '���������� ����� ��������� ������ ������', '��������', MB_Iconwarning)
    Else
    Begin
        FCopyList.Tail^.Next := FCopyList.Head; //�������� ��������� ������
        Head := FCopyList.Head;
        While IsNotFilled do
        Begin
            I := 0;
            TotalWeight := StrToInt(WeightEdit.Text);
            TotalValue := StrToInt(ValueEdit.Text);
            CountType := StrToInt(CountTypeEdit.Text);
            SetLength(FArr, Length(FArr) + 1);
            LastNode := Nil;
            IsNotFilled := False;
            While I < StrToInt(CountTypeEdit.Text) do
            Begin
                TempWeight := TotalWeight div CountType;
                TempValue := TotalValue div CountType;
                Current := Head.Info.CandyItself;
                While (Current <> Nil) do
                Begin
                    New(NewNode);
                    NewNode.TypeofCandy := Head.Info.TypeOfCandy;
                    NewNode.Name := Current.Name;
                    NewNode.Next := Nil;
                    NewNode.Sugar := 0;
                    NewNode.Count := 0;
                    While (TempWeight - Current.Weight > -1) and (Current.Count > 0) and
                    (TempValue - Current.ValueForOne > -1) do
                    Begin
                        IsNotFilled := True;     
                        Dec(Current.Count);
                        Inc(NewNode.Count);
                        Inc(NewNode.Sugar, Current.AmountOfSugar);
                        TempWeight := TempWeight - Current.Weight;
                        TempValue := TempValue - Current.ValueForOne;        
                    End;
                    
                    If NewNode.Count = 0 Then
                        Dispose(NewNode)
                    Else
                    Begin
                        If FArr[High(FArr)] = Nil Then
                            FArr[High(FArr)] := NewNode
                        Else
                            LastNode^.Next := NewNode;
                        LastNode := NewNode;
                    End;
                    Current := Current^.Next;
                End;
                Head := Head^.Next;
                TotalWeight := TotalWeight - (TotalWeight div CountType) + TempWeight;
                TotalValue := TotalValue - (TotalValue div CountType) + TempValue;
                Dec(CountType);
                Inc(I);
            End;
        End;
        SetLength(FArr, Length(FArr) - 1);
    End;
    SetLength(FSugarCountArray, Length(FArr));
    For I := 0 to High(FArr) do
    Begin
        FSugarCountArray[I] := 0;
        Temp := FArr[I];
        While Temp <> Nil do
        Begin   
            Inc(FSugarCountArray[I], Temp.Sugar);
            Temp := Temp^.Next;
        End;
    End;
    QSort(FSugarCountArray, Low(FSugarCountArray), High(FSugarCountArray));
    TreeView1.Items.Clear;
    For I := 0 to High(FArr) do
    Begin
        Temp := FArr[I];
        Item := TreeView1.Items.Add(nil, '������� ' + IntToStr(I + 1));
        While Temp <> Nil do
        Begin
            GiftNode := TreeView1.Items.AddChild(Item, Temp^.TypeofCandy);
            GiftNode.Text := Format('%s - ��� ��������: %s, �����: %d, ���������� ������: %s', [GiftNode.Text, Temp^.Name, Temp^.Count, IntToStr(Temp^.Sugar) + '��']);
            Temp := Temp^.Next;
        End;
    End;
    AddGiftBtn.Enabled := False;
end;

Procedure TGiftForm.WeightEditChange(Sender: TObject);
Var
    I: Integer;
begin
    AddGiftBtn.Enabled := (WeightEdit.GetTextLen > 0) and (CountTypeEdit.GetTextLen > 0) and
    (ValueEdit.GetTextLen > 0);
    If (TLabeledEdit(Sender).GetTextLen > 0) and (TLabeledEdit(Sender).Text[1] = '0') then
    begin
        I := 1;
        While TLabeledEdit(Sender).Text[I] = '0' do
            Inc(I);
        TLabeledEdit(Sender).Text := Copy(TLabeledEdit(Sender).Text, I, TLabeledEdit(Sender).GetTextLen - I + 1);
    end;
end;

Procedure TGiftForm.WeightEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
Begin
    If (Shift = [ssCtrl]) and (Key = Ord('A')) then
        TLabeledEdit(Sender).SelectAll;
    TEdit(Sender).ReadOnly := (((Shift=[ssShift]) and (Key = VK_INSERT)) or (Shift=[ssCtrl]) or (Shift=[ssAlt]))
End;

{$R *.dfm}

end.
