object FormAdr: TFormAdr
  Left = 192
  Top = 103
  BorderStyle = bsDialog
  Caption = 'Adres�r'
  ClientHeight = 200
  ClientWidth = 280
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object DirectoryListBox: TDirectoryListBox
    Left = 8
    Top = 32
    Width = 265
    Height = 129
    ItemHeight = 16
    TabOrder = 1
  end
  object DriveComboBox: TDriveComboBox
    Left = 8
    Top = 8
    Width = 265
    Height = 19
    DirList = DirectoryListBox
    TabOrder = 0
  end
  object Button1: TButton
    Left = 103
    Top = 168
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 2
    OnClick = Button1Click
  end
end
