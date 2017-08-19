program FirmataComportAPI;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  FirmataUnitReadComportAPII in 'FirmataUnitReadComportAPII.pas' {FormFirmataReadComportAPI};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormFirmataReadComportAPI, FormFirmataReadComportAPI);
  Application.Run;
end.
