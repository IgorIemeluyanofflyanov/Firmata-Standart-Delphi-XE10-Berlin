object FormFirmataReadComportAPI: TFormFirmataReadComportAPI
  Left = 0
  Top = 0
  Caption = 'FormFirmataReadComportAPI'
  ClientHeight = 373
  ClientWidth = 1070
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    1070
    373)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 120
    Top = 23
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 608
    Top = 46
    Width = 32
    Height = 13
    Caption = 'Closed'
  end
  object AnalogValue: TLabel
    Left = 144
    Top = 158
    Width = 59
    Height = 13
    Caption = 'AnalogValue'
  end
  object lbFirmaware: TLabel
    Left = 224
    Top = 200
    Width = 58
    Height = 13
    Caption = 'lbFirmaware'
  end
  object chkActive: TCheckBox
    Left = 504
    Top = 103
    Width = 97
    Height = 17
    Caption = 'RX Active'
    TabOrder = 0
    OnClick = chkActiveClick
  end
  object Memo1: TMemo
    Left = 8
    Top = 240
    Width = 274
    Height = 100
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    Lines.Strings = (
      'Memo1')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 1
    WantTabs = True
    WordWrap = False
    OnKeyPress = Memo1KeyPress
  end
  object ComportName: TEdit
    Left = 208
    Top = 23
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '\\.\COM14'
  end
  object Ver: TButton
    Left = 376
    Top = 68
    Width = 75
    Height = 25
    Caption = 'Ver'
    TabOrder = 3
    OnClick = VerClick
  end
  object Pin4: TCheckBox
    Tag = 4
    Left = 47
    Top = 72
    Width = 114
    Height = 17
    Caption = '4'
    TabOrder = 4
    OnClick = CheckBox1Click
  end
  object Pin9: TCheckBox
    Left = 47
    Top = 95
    Width = 74
    Height = 17
    Caption = 'Pin9'
    TabOrder = 5
  end
  object Pin50: TCheckBox
    Tag = 9
    Left = 47
    Top = 95
    Width = 74
    Height = 17
    Caption = '9'
    TabOrder = 6
    OnClick = CheckBox1Click
  end
  object Pin10: TCheckBox
    Tag = 10
    Left = 47
    Top = 127
    Width = 74
    Height = 17
    Caption = '10'
    TabOrder = 7
    OnClick = CheckBox1Click
  end
  object CheckBox1: TCheckBox
    Tag = 11
    Left = 47
    Top = 157
    Width = 74
    Height = 17
    Caption = '11'
    TabOrder = 8
    OnClick = CheckBox1Click
  end
  object CheckBox2: TCheckBox
    Tag = 9
    Left = 208
    Top = 72
    Width = 74
    Height = 17
    Caption = '8'
    TabOrder = 9
    OnClick = CheckBox1Click
  end
  object CheckBox3: TCheckBox
    Tag = 9
    Left = 208
    Top = 95
    Width = 74
    Height = 17
    Caption = '7'
    TabOrder = 10
    OnClick = CheckBox1Click
  end
  object CheckBox4: TCheckBox
    Tag = 9
    Left = 208
    Top = 127
    Width = 74
    Height = 17
    Caption = '3'
    TabOrder = 11
    OnClick = CheckBox1Click
  end
  object Button1: TButton
    Left = 504
    Top = 41
    Width = 75
    Height = 25
    Caption = 'Open'
    TabOrder = 12
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 504
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 13
    OnClick = Button2Click
  end
  object Memo2: TMemo
    Left = 400
    Top = 145
    Width = 649
    Height = 195
    Lines.Strings = (
      'Memo2')
    ScrollBars = ssBoth
    TabOrder = 14
    WordWrap = False
  end
end
