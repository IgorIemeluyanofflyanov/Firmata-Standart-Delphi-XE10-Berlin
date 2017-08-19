
// Port to Delphi 10.2 Berlin by Igor Pakemonoff (vectorgmbh@gmail.com) 8 aug 2017 from
// Firmata GUI-friendly queries test
// *  Copyright 2010, Paul Stoffregen (paul@pjrc.com)
// *

unit FirmataUnitReadComportAPII;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFormFirmataReadComportAPI = class(TForm)
    chkActive: TCheckBox;
    Memo1: TMemo;
    Label1: TLabel;
    ComportName: TEdit;
    Ver: TButton;
    Pin4: TCheckBox;
    Pin9: TCheckBox;
    Pin50: TCheckBox;
    Pin10: TCheckBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    Label2: TLabel;
    AnalogValue: TLabel;
    lbFirmaware: TLabel;
    Memo2: TMemo;
    procedure chkActiveClick(Sender: TObject);
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure VerClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormFirmataReadComportAPI: TFormFirmataReadComportAPI;

procedure firmata_parse(const p: byte);

implementation

{$R *.dfm}

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  StrUtils, Math;

var
  CommHandle: THandle;

  i, iErrs, iByteRecive, iByteSend: Cardinal;
  Recive, Transmit: array [0 .. 10000] of byte;
  FStat: TComStat;
  DCB: _DCB;
  aChar: AnsiChar;
  // TransMask: dword;

const
  MODE_INPUT = $00;
  MODE_OUTPUT = $01;
  MODE_ANALOG = $02;
  MODE_PWM = $03;
  MODE_SERVO = $04;
  MODE_SHIFT = $05;
  MODE_I2C = $06;

  START_SYSEX = $F0; // start a MIDI Sysex message
  END_SYSEX = $F7; // end a MIDI Sysex message
  PIN_MODE_QUERY = $72; // ask for current and supported pin modes
  PIN_MODE_RESPONSE = $73; // reply with current and supported pin modes
  PIN_STATE_QUERY = $6D;
  PIN_STATE_RESPONSE = $6E;
  CAPABILITY_QUERY = $6B;
  CAPABILITY_RESPONSE = $6C;
  ANALOG_MAPPING_QUERY = $69;
  ANALOG_MAPPING_RESPONSE = $6A;
  REPORT_FIRMWARE = $79; // report name and version of the firmware

procedure TFormFirmataReadComportAPI.VerClick(Sender: TObject);
begin

  Transmit[0] := START_SYSEX;
  Transmit[1] := REPORT_FIRMWARE; // read firmata name & version
  Transmit[2] := END_SYSEX;
  WriteFile(CommHandle, Transmit, 3, iByteSend, nil);

end;

VAR
  PinHigh: set of byte;

  type
  s_pin = record
    mode, analog_channel: byte;
    supported_modes: uint64;
    value: uint32;
  end;

var
  pins: array [0 .. 127] of s_pin;

  firmware: AnsiString = '';

procedure init_data;
var i : word;
begin
	for  i := 0 to 127 do
  begin
		pins[i].mode := 255;
		pins[i].analog_channel := 127;
		pins[i].supported_modes := 0;
		pins[i].value := 0;
end;
end;


procedure TFormFirmataReadComportAPI.Button1Click(Sender: TObject);
begin
  CommHandle := CreateFile(PChar(ComportName.Text), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
  GetCommState(CommHandle, DCB);
  DCB.BaudRate := CBR_57600;
  DCB.Parity := NOPARITY;
  DCB.ByteSize := 8;
  DCB.StopBits := OneStopBit;
  SetCommState(CommHandle, DCB);
  Label2.Caption := Format('Handle %d', [CommHandle]);
  init_data;
  FormFirmataReadComportAPI.Memo2.Clear;
end;

procedure TFormFirmataReadComportAPI.Button2Click(Sender: TObject);
begin
  CloseHandle(CommHandle);
  Label2.Caption := 'Closed';
end;

procedure TFormFirmataReadComportAPI.CheckBox1Click(Sender: TObject);
var
  i, p, port_num, port_val, pin: byte;

begin
  pin := StrToInt((Sender as TCheckBox).Caption);

  if (Sender as TCheckBox).Checked then
    PinHigh := PinHigh + [pin]
  ELSE
    PinHigh := PinHigh - [pin];

  for pin in [3 .. 11] do
  begin
    port_num := pin div 8;
    port_val := 0;
    for i := 0 to 7 do
    begin
      p := port_num * 8 + i;
      if p in PinHigh then
        port_val := port_val OR (1 SHL i);
    end;

    Transmit[0] := $90 OR port_num;
    Transmit[1] := port_val AND $7F;
    Transmit[2] := (port_val SHR 7) AND $7F;
    WriteFile(CommHandle, Transmit, 3, iByteSend, nil);
  end;

end;



procedure TFormFirmataReadComportAPI.chkActiveClick(Sender: TObject);

var
  s: AnsiString;

begin
  if not chkActive.Checked then
    exit;

  while chkActive.Checked do
  begin

    Application.ProcessMessages;

    // TransMask := 0;

    // SetCommMask(CommHandle, EV_RXCHAR );
    // WaitCommEvent(CommHandle, TransMask, nil);

    ClearCommError(CommHandle, iErrs, @FStat);
    ReadFile(CommHandle, Recive, min(10000, FStat.cbInQue), iByteRecive, nil);

    s := '';
    if iByteRecive > 0 then
    begin
      Label1.Caption := Format(' bytes %d %d', [FStat.cbInQue, iByteRecive]);
      for i := 0 to iByteRecive - 1 do
      begin
        s := s + AnsiChar(Recive[i]);
        firmata_parse(Recive[i]);
      end
    end;

    Memo1.Text := Memo1.Text + s;

    AnalogValue.Caption := Format('pin14=%d, pin15=%d', [pins[14].value, pins[15].value]);
    lbFirmaware.Caption := firmware;

    while length(Memo1.Text) > 8000 do
      Memo1.Lines.Delete(0);

  end;

end;

procedure TFormFirmataReadComportAPI.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  chkActive.Checked := false;
end;

procedure TFormFirmataReadComportAPI.FormCreate(Sender: TObject);
begin
  PinHigh := [];
end;

procedure TFormFirmataReadComportAPI.Memo1KeyPress(Sender: TObject; var Key: Char);
begin
  Transmit[0] := Ord(Key);
  WriteFile(CommHandle, Transmit, 1, iByteSend, nil);
end;

var
  parse_command_len, parse_count: word;

  parse_buff: array [0 .. 1000] of byte;

procedure firmata_endParse;
var
  cmd: byte;
  n, mask, pin: word;

  port_num, port_val, analog_ch, analog_val: integer;

  i, len: word;

begin
  cmd := parse_buff[0] and $F0;

  if (cmd = $E0) and (parse_count = 3) then
  begin
    analog_ch := parse_buff[0] and $0F;
    analog_val := parse_buff[1] or (parse_buff[2] shl 7);
    for pin := 0 to 127 do
			if pins[pin].analog_channel = analog_ch then
				pins[pin].value := analog_val;
    exit;
  end;

  if (cmd = $90) and (parse_count = 3) then
  begin
    port_num := parse_buff[0] and $0F;
    port_val := parse_buff[1] or (parse_buff[2] shl 7);
    mask := 1;
    for pin := port_num * 8 to 128 do
    begin
      if mask and $FF = 0 then
        break;
      mask := mask shl 1;

      if pins[pin].mode = MODE_INPUT then
        pins[pin].value := ifthen(port_val and mask <> 0, 1, 0);
    end;
    exit;
  end;

  if not((parse_buff[0] = START_SYSEX) and (parse_buff[parse_count - 1] = END_SYSEX)) then
    exit;

  if parse_buff[1] = REPORT_FIRMWARE then
  begin
    i := 4;
    firmware := '';
    while i <= parse_count - 2 do
    begin
      firmware := firmware + AnsiChar((parse_buff[i] and $7F) or ((parse_buff[i + 1] and $7F) shl 7));
      inc(i, 2);
    end;
    firmware := firmware + '-' + AnsiChar(parse_buff[2] + Ord('0')) + '.' + AnsiChar(parse_buff[3] + Ord('0'));

    // query the board's capabilities only after hearing the
    // REPORT_FIRMWARE message.  For boards that reset when
    // the port open (eg, Arduino with reset=DTR), they are
    // not ready to communicate for some time, so the only
    // way to reliably query their capabilities is to wait
    // until the REPORT_FIRMWARE message is heard.
    Transmit[0] := START_SYSEX;
    Transmit[1] := ANALOG_MAPPING_QUERY; // read analog to pin # info
    Transmit[2] := END_SYSEX;
    Transmit[3] := START_SYSEX;
    Transmit[4] := CAPABILITY_QUERY; // read capabilities
    Transmit[5] := END_SYSEX;
    len := 5;
    for i := 0 to 15 do
    begin
      inc(len);
      Transmit[len] := $C0 or i; // report analog
      inc(len);
      Transmit[len] := 1;
      inc(len);
      Transmit[len] := $D0 or i; // report digital
      inc(len);
      Transmit[len] := 1;
    end;
    WriteFile(CommHandle, Transmit, len + 1, iByteSend, nil);
    exit;
  end;

  if parse_buff[1] = CAPABILITY_RESPONSE then
  begin
    for pin := 0 to 127 do
      pins[pin].supported_modes := 0;

    n := 0;
    pin := 0;
    for i := 2 to parse_count do
    begin
      if parse_buff[i] = 127 then
      begin
        inc(pin);
        n := 0;
        continue;
      end;
      if n = 0 then
      begin
        // first byte is supported mode
        pins[pin].supported_modes := pins[pin].supported_modes or (1 shl parse_buff[i]);
        n := n XOR 1;
      end;
    end;
    // send a state query for for every pin with any modes
    for pin := 0 to 127 do
    begin
      len := 0;
      if pins[pin].supported_modes > 0 then
      begin
        Transmit[len] := START_SYSEX;
        inc(len);
        Transmit[len] := PIN_STATE_QUERY;
        inc(len);
        Transmit[len] := pin;
        inc(len);
        Transmit[len] := END_SYSEX;
        inc(len);
      end;
      WriteFile(CommHandle, Transmit, len, iByteSend, nil);
    end;
    exit;
  end;

  if parse_buff[1] = ANALOG_MAPPING_RESPONSE then
  begin
    pin := 0;
    for i := 2 to parse_count - 1 do
    begin
      pins[pin].analog_channel := parse_buff[i];
      inc(pin);
    end;
    exit;
  end;

  if (parse_buff[1] = PIN_STATE_RESPONSE) and (parse_count >= 6) then
  begin
    pin := parse_buff[2];
    pins[pin].mode := parse_buff[3];
    pins[pin].value := parse_buff[4];
    if parse_count > 6 then
      pins[pin].value := pins[pin].value or (parse_buff[5] shl 7);
    if parse_count > 7 then
      pins[pin].value := pins[pin].value or (parse_buff[6] shl 14);
    with FormFirmataReadComportAPI.Memo2.Lines, pins[pin] do
      Add(format(
      'mode %d	,	analog_channel %d, supported_modes %d, value %d',
      	[mode 	,	analog_channel , supported_modes , value] ));

  end;
end;

procedure firmata_parse(const p: byte);
var
  msn: byte;
begin
  msn := p and $F0;
  if (msn = $E0) or (msn = $90) or (p = $F9) then
  begin
    parse_command_len := 3;
    parse_count := 0;
  end
  else if (msn = $C0) or (msn = $D0) then
  begin
    parse_command_len := 2;
    parse_count := 0;
  end
  else if p = START_SYSEX then
  begin
    parse_count := 0;
    parse_command_len := 1000;
  end
  else if p = END_SYSEX then
    parse_command_len := parse_count + 1
  else if p and $80 > 0 then
  begin
    parse_command_len := 1;
    parse_count := 0;
  end;

  if parse_count < 1000 then
  begin
    parse_buff[parse_count] := p;
    inc(parse_count);
  end;
  if parse_count = parse_command_len then
  begin
    firmata_endParse;
    parse_count := 0;
    parse_command_len := 0;
  end;
end;

end.
