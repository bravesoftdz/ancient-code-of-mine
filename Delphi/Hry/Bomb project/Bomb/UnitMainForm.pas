unit UnitMainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Menus;

type
  TMainForm = class(TForm)
    Image: TImage;
    MainMenu: TMainMenu;
    Hra: TMenuItem;
    HraNova: TMenuItem;
    HraKoniec: TMenuItem;
    procedure HraKoniecClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HraNovaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses Constants, ClassLevel;

{$R *.DFM}

//==============================================================================
//==============================================================================
//
//                               Constructor
//
//==============================================================================
//==============================================================================

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Level := TLevel.Create;
end;

//==============================================================================
//==============================================================================
//
//                                Destructor
//
//==============================================================================
//==============================================================================

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Level.Free;
end;

//==============================================================================
//==============================================================================
//
//                                Main menu
//
//==============================================================================
//==============================================================================

procedure TMainForm.HraKoniecClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.HraNovaClick(Sender: TObject);
begin
  Level.LoadFromFile( LEVEL_DIR );
end;

end.
