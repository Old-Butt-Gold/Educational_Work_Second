unit MainUnit;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.ComCtrls, CommCtrl, Vcl.Menus, Vcl.WinXCtrls, PngImage, Jpeg,
  System.ImageList, Vcl.ImgList;
type

  PCandy = ^TCandy;
  TCandy = Record
      Name: String[15];
      Count, Weight, ValueForOne: Integer;
      AmountOfSugar: Integer;
      Next: PCandy;
  End;

  TInfo = Record
      Code: Integer;
      TypeOfCandy: String[15];
      CandyItself: PCandy;
  End;

  PCandyType = ^TcandyType;
  TCandyType = Record
      Info: TInfo;
      Next: PCandyType;
  End;

  TTotalCandyType = Record
      Head, Tail: PCandyType;
  End;

  TMainForm = class(TForm)
    LViewTeam: TListView;
    BitBtn2: TBitBtn;
    PanelAnalysis: TPanel;
    PanelAdd: TPanel;
    PlayerListView: TListView;
    PanelPlayers: TPanel;
    Label2: TLabel;
    AddPlayerBtn: TBitBtn;
    MainMenu: TMainMenu;
    PopupMenu: TPopupMenu;
    N1: TMenuItem;
    OpenFile: TMenuItem;
    SaveFile: TMenuItem;
    PlayerRatings: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    SplitView1: TSplitView;
    ImageList1: TImageList;
    Procedure InsertInList(InsNode: TCandyType);
    Procedure RemoveCandyType(Code: Integer);
    procedure LViewTeamSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure LViewTeamDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LViewTeamKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BitBtn2Click(Sender: TObject);
    Procedure AddToListView;
    Function  FindTypeByCode(Code: Integer): PCandyType;
    Procedure ChangeRowInListView(Item: TListItem; CurrentNode: PCandyType);
    procedure AddCandyBtnClick(Sender: TObject);
    Procedure AddToCandyListView(CurrentNode: PCandy);
    Procedure ShowPlayers(Temp: PCandyType);
    procedure PlayerListViewDblClick(Sender: TObject);
    Procedure SetNewCandy(Item: TListItem; Temp: PCandy);
    procedure PlayerListViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PlayerRatingsClick(Sender: TObject);
    //procedure SaveFileClick(Sender: TObject);
    //procedure OpenFileClick(Sender: TObject);
    Procedure ClearLinkedList;
    Procedure DeleteCandy(Var Head: PCandy; Name: String);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    Function FindCandyByName(Name: String; Node: PCandy): PCandy;
    Procedure InsertCandy(Var Head: PCandy; Data: TCandy);
    procedure OpenFileClick(Sender: TObject);
    procedure SaveFileClick(Sender: TObject);
  private
      FCandyList: TTotalCandyType;
  public
      Property CandyList: TTotalCandyType Read FCandyList;
  end;
var
  MainForm: TMainForm;
implementation
{$R *.dfm}
uses TypeAddUnit, CandyAddUnit, GiftUnit;
Procedure TMainForm.AddToListView;
Var
    Item: TListItem;
Begin
    Item := LViewTeam.Items.Add;
    Item.Caption := IntToStr(FCandyList.Tail^.Info.Code);
    Item.SubItems.Add(FCandyList.Tail^.Info.TypeOfCandy);
End;
Procedure TMainForm.ChangeRowInListView(Item: TListItem; CurrentNode: PCandyType);
Begin
    Item.Caption := IntToStr(CurrentNode^.Info.Code);
    Item.SubItems.Strings[0] := CurrentNode^.Info.TypeOfCandy;
End;
Procedure TMainForm.AddToCandyListView(CurrentNode: PCandy);
Var
    Item: TListItem;
Begin
    Item := PlayerListView.Items.Add;
    Item.Caption := CurrentNode^.Name;
    Item.SubItems.Add(IntToStr(CurrentNode^.Count));
    Item.SubItems.Add(IntToStr(CurrentNode^.Weight) + ' �');
    Item.SubItems.Add(IntToStr(CurrentNode.ValueForOne) + '$');
    Item.SubItems.Add(IntToStr(CurrentNode^.AmountOfSugar) + ' ��');
End;
procedure TMainForm.AddCandyBtnClick(Sender: TObject);
Var
    Temp: PCandy;
begin
    AddCandyForm.AddBtn.Visible := True;
    AddCandyForm.ChangeBtn.Visible := False;
    AddCandyForm.ShowModal;
    If AddCandyForm.ModalResult = MrYes Then
    Begin
        Temp := AddCandyForm.FCurrentNode.Info.CandyItself;
        While Temp^.Next <> Nil do
            Temp := Temp^.Next;
        AddToCandyListView(Temp);
    End;
end;
procedure TMainForm.BitBtn2Click(Sender: TObject);
begin
    AddTypeForm.ChangeBtn.Visible := False;
    AddTypeForm.AddBtn.Visible := True;
    AddTypeForm.ShowModal;
    If AddTypeForm.ModalResult = MrYes Then
    Begin
        AddToListView;
        SaveFile.Enabled := True;
    End;
end;
procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    ClearLinkedList;
end;
procedure TMainForm.FormCreate(Sender: TObject);
begin
    LViewTeam.Columns[0].Width := LVSCW_AUTOSIZE_USEHEADER;
end;
    
procedure TMainForm.FormShow(Sender: TObject);
begin
    LViewTeam.Width := LViewTeam.Width + 1;
    LViewTeam.Width := LViewTeam.Width - 1;
end;
Function TMainForm.FindTypeByCode(Code: Integer): PCandyType;
Var
    CurrentNode: PCandyType;
    IsFounded: Boolean;
Begin
    Result := Nil;
    IsFounded := False;
    CurrentNode := FCandyList.Head;
    While (CurrentNode <> nil) and Not(IsFounded) do
    Begin
        If CurrentNode^.Info.Code = Code Then
        Begin
            IsFounded := True;
            Result := CurrentNode;
        End;
        CurrentNode := CurrentNode^.Next;
    End;
End;
Procedure TMainForm.RemoveCandyType(Code: Integer);
Var
    CurrentNode, PreviousNode: PCandyType;
begin
    CurrentNode := FCandyList.Head;
    PreviousNode := nil;
    While (CurrentNode <> nil) and (CurrentNode.Info.Code <> Code) do
    begin
        PreviousNode := CurrentNode;
        CurrentNode := CurrentNode.Next;
    end;
    If CurrentNode <> nil then
    begin
        If CurrentNode = FCandyList.Head then
            FCandyList.Head := FCandyList.Head^.Next
        Else
            PreviousNode.Next := CurrentNode^.Next;
        If CurrentNode = FCandyList.Tail then
            FCandyList.Tail := PreviousNode;
        Dispose(CurrentNode);
    end;
end;
procedure TMainForm.InsertInList(InsNode: TCandyType);
Var
    NewNode: PCandyType;
begin
    New(NewNode);
    NewNode^.Info := InsNode.Info;
    NewNode^.Next := Nil;
    If FCandyList.Head = nil Then
    Begin
        FCandyList.Head := NewNode;
        FCandyList.Tail := NewNode;
    End
    Else
    Begin
        FCandyList.Tail^.Next := NewNode;
        FCandyList.Tail := FCandyList.Tail^.Next;
    End;
end;
procedure TMainForm.LViewTeamDblClick(Sender: TObject);
var
    Item: TListItem;
    CurrentNode: PCandyType;
begin
    Item := LViewTeam.Selected;
    If Assigned(Item) and Item.Selected then
    begin
        CurrentNode := FindTypeByCode(StrToInt(Item.Caption));
        AddTypeForm.SetCandyEdits(CurrentNode);
        AddTypeForm.AddBtn.Visible := False;
        AddTypeForm.ChangeBtn.Visible := True;
        AddTypeForm.ShowModal;
        If AddTypeForm.ModalResult = MrYes Then
            ChangeRowInListView(Item, CurrentNode);
    end;
end;
procedure TMainForm.LViewTeamKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    If (Key = VK_DELETE) and (LViewTeam.ItemIndex <> -1) and
    (MessageBox(MainForm.Handle, '�� ������ ������� ������ ��� ��������?', '��������', MB_YESNO + MB_ICONQUESTION) = ID_YES) Then
    Begin
        RemoveCandyType(StrToInt(LViewTeam.Selected.Caption));
        LViewTeam.DeleteSelected;
        SaveFile.Enabled := LViewTeam.GetCount <> 0;
    End;
end;
Procedure TMainForm.ShowPlayers(Temp: PCandyType);
Var
    CurrentNode: PCandy;
Begin
    CurrentNode := Temp^.Info.CandyItself;
    While CurrentNode <> Nil do
    Begin
        AddToCandyListView(CurrentNode);
        CurrentNode := CurrentNode^.Next;
    End;
End;
procedure TMainForm.LViewTeamSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
    If Selected Then
    Begin
        AddCandyForm.FCurrentNode := FindTypeByCode(StrToInt(Item.Caption));
        PlayerListView.Clear;
        ShowPlayers(AddCandyForm.FCurrentNode);
        AddPlayerBtn.Enabled := True;
    End
    Else
    Begin
        PlayerListView.Clear;
        AddPlayerBtn.Enabled := False;
    End;
end;
procedure TMainForm.OpenFileClick(Sender: TObject);
Var
    FileInput: File of TInfo;
    Temp: PCandyType;
    Item: TListItem;
begin
    If OpenDialog.Execute Then
    Begin
        Try
            Try
                AssignFile(FileInput, ChangeFileExt(OpenDialog.FileName, '.dat'));
                Reset(FileInput);
                ClearLinkedList;
                PlayerListView.Clear;
                LViewTeam.Clear;
                While Not Eof(FileInput) do
                Begin
                    New(Temp);
                    Temp^.Next := Nil;
                    Read(FileInput, Temp^.Info);
                    Temp^.Info.CandyItself := Nil;
                    InsertInList(Temp^);
                    Dispose(Temp);
                End;
                Temp := FCandyList.Head;
                While Temp <> Nil do
                Begin
                    Item := LViewTeam.Items.Add;
                    Item.Caption := IntToStr(Temp^.Info.Code);
                    Item.SubItems.Add(Temp^.Info.TypeOfCandy);
                    Temp := Temp^.Next;
                End;
                SaveFile.Enabled := True;
            Except
                MessageBox(Handle, '���� �����������!'#13#10 + '���������, ����� ��� ���� ���� ���������� .dat � �������� ���� ������: '#13#10
                + '1. Code: Integer'#13#10 + '2. TypeName: String[15]', '��������!', MB_OK + MB_ICONWARNING);
            End;
        Finally
            If FileExists(ChangeFileExt(SaveDialog.FileName, '.dat')) Then
                CloseFile(FileInput);
        End;
    End;
end;

procedure TMainForm.ClearLinkedList;
Var
    Current, NextNode: PCandyType;
begin
    Current := FCandyList.Head;
    while Current <> nil do
    begin
        NextNode := Current^.Next;
        Dispose(Current);
        Current := nextNode;
    end;
    FCandyList.Head := nil;
    FCandyList.Tail := nil;
end;

Procedure TMainForm.InsertCandy(Var Head: PCandy; Data: TCandy);
Var
    Temp: PCandy;
    Current: PCandy;
Begin
    New(Temp);
    Temp^ := Data;
    Temp.Next := Nil;
    Current := Head;
    If Head = Nil Then
        Head := Temp
    Else
    Begin
        While Current^.Next <> Nil do
            Current := Current^.Next;
        Current^.Next := Temp;
    End;
End;
procedure TMainForm.SaveFileClick(Sender: TObject);
Var
    FileOutput: File of TInfo;
    Temp: PCandyType;
begin
    If SaveDialog.Execute Then
    Begin
        Try
            Try
                AssignFile(FileOutput, ChangeFileExt(SaveDialog.FileName, '.dat'));
                Rewrite(FileOutput);
                Temp := FCandyList.Head;
                While Temp <> Nil do
                Begin
                    Write(FileOutput, Temp^.Info);
                    Temp := Temp^.Next;
                End;
            Except
                MessageBox(Handle, '���� �����������!', '��������!', MB_OK + MB_ICONWARNING);
            End;
        Finally
            CloseFile(FileOutput);
        End;
    End;
end;

Procedure TMainForm.SetNewCandy(Item: TListItem; Temp: PCandy);
Begin
    Item.Caption := Temp^.Name;
    Item.SubItems.Strings[0] := IntToStr(Temp^.Count);
    Item.SubItems.Strings[1] := IntToStr(Temp^.Weight);
    Item.SubItems.Strings[2] := IntToStr(Temp^.ValueForOne);
    Item.SubItems.Strings[3] := IntToStr(Temp^.AmountOfSugar) + ' ��';
End;
Function TMainForm.FindCandyByName(Name: String; Node: PCandy): PCandy;
Var
    IsFounded: Boolean;
Begin
    Result := Nil;
    IsFounded := False;
    While (Node <> nil) and Not(IsFounded) do
    Begin
        If Node.Name = Name Then
        Begin
            IsFounded := True;
            Result := Node;
        End;
        Node := Node^.Next;
    End;
End;
procedure TMainForm.PlayerListViewDblClick(Sender: TObject);
var
    Item: TListItem;
    CurrentNode: PCandyType;
begin
    Item := PlayerListView.Selected;
    If Assigned(Item) and Item.Selected then
    begin
        AddCandyForm.AddBtn.Visible := False;
        AddCandyForm.ChangeBtn.Visible := True;
        AddCandyForm.CurrentCandy := FindCandyByName(Item.Caption, AddCandyForm.FCurrentNode.Info.CandyItself);
        AddCandyForm.SetPlayerEdits(AddCandyForm.CurrentCandy);
        AddCandyForm.ShowModal;
        If AddCandyForm.ModalResult = MrYes Then
            SetNewCandy(Item, AddCandyForm.FCurrentNode.Info.CandyItself);
    end;
end;
Procedure TMainForm.DeleteCandy(Var Head: PCandy; Name: String);
Var
    CurrentNode, PreviousNode: PCandy;
begin
    CurrentNode := Head;
    PreviousNode := nil;
    While (CurrentNode <> nil) and (CurrentNode.Name <> Name) do
    begin
        PreviousNode := CurrentNode;
        CurrentNode := CurrentNode.Next;
    end;
    If CurrentNode <> nil then
    begin
        If CurrentNode = Head then
            Head := Head^.Next
        Else
            PreviousNode^.Next := CurrentNode^.Next;
        Dispose(CurrentNode);
    end;
End;
procedure TMainForm.PlayerListViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
Var
    Item: TListItem;
    Index, I: Integer;
    CurrentNode: PCandyType;
    CurrentCandy: PCandy;
begin
    If (Key = VK_DELETE) and (PlayerListView.ItemIndex <> -1) and
    (MessageBox(MainForm.Handle, '�� ������ ������� ������� ������?', '��������', MB_YESNO + MB_ICONQUESTION) = ID_YES) Then
    Begin
        Item := PlayerListView.Selected;
        Index := Item.Index;
        CurrentNode := AddCandyForm.FCurrentNode;
        DeleteCandy(CurrentNode.Info.CandyItself, Item.Caption);
        PlayerListView.DeleteSelected;
    End;
end;
procedure TMainForm.PlayerRatingsClick(Sender: TObject);
begin
    GiftForm.ShowModal;
end;

end.
