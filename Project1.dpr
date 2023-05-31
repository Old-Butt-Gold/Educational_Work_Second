program Project1;
uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  Vcl.Themes,
  Vcl.Styles,
  TypeAddUnit in 'TypeAddUnit.pas' {AddTypeForm},
  CandyAddUnit in 'CandyAddUnit.pas' {AddCandyForm},
  GiftUnit in 'GiftUnit.pas' {GiftForm};

{$R *.res}
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Tablet Dark');
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAddTypeForm, AddTypeForm);
  Application.CreateForm(TAddCandyForm, AddCandyForm);
  Application.CreateForm(TGiftForm, GiftForm);
  Application.Run;
end.
