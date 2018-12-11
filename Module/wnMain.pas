unit wnMain;

interface

uses
  Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.AppEvnts, Vcl.StdCtrls, uRouleMap,
  Web.HTTPProd, Web.ReqMulti, uConfig, ThSessionClear, SynHTTPWebBrokerBridge,
  Web.HTTPApp, Vcl.ExtCtrls, System.IniFiles;

type
  TMain = class(TForm)
    TrayIcon1: TTrayIcon;
    Panel1: TPanel;
    ButtonOpenBrowser: TButton;
    btn1: TButton;
    grp1: TGroupBox;
    mmolog: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure ButtonOpenBrowserClick(Sender: TObject);
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure FormShow(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btn1Click(Sender: TObject);
  private
    run: Boolean;
    FServer: TSynHTTPWebBrokerBridge;
    procedure StartServer;
    procedure CloseServer;
    { Private declarations }
  public

    { Public declarations }
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

uses
  Winapi.Windows, Winapi.ShellApi, command, wnDM, SessionList;

procedure TMain.WMSysCommand(var Msg: TWMSysCommand);
begin
  inherited;
  if Msg.CmdType = SC_MINIMIZE then // �����յ���С����Ϣ
  begin
    Application.Minimize; // ��С������
    ShowWindow(Application.Handle, SW_HIDE); // ����������ͼ��
  end;
end;

procedure TMain.btn1Click(Sender: TObject);
begin
  Close;
end;

procedure TMain.ButtonOpenBrowserClick(Sender: TObject);
var
  LURL: string;
  FIniFile: TIniFile;
  FPort: string;
begin
  FIniFile := TIniFile.Create(WebApplicationDirectory + config);
  FPort := FIniFile.ReadString('Server', 'Port', '8001');
  FIniFile.Free;
  LURL := Format('http://localhost:%s', [FPort]);
  ShellExecute(0, nil, PChar(LURL), nil, nil, SW_SHOWNOACTIVATE);
end;

procedure TMain.CloseServer;
begin
  FreeAndNil(SessionListMap);
  FreeAndNil(RouleMap);

  FreeAndNil(DM);

end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseServer;
  FServer.Free;
  FServer := nil;

end;

procedure TMain.FormCreate(Sender: TObject);
begin

  Caption := Application.Title;
  FServer := TSynHTTPWebBrokerBridge.Create(Self);
  TrayIcon1.SetDefaultIcon;
  TrayIcon1.Visible := true;
  mmolog.Clear;
  StartServer;
end;

procedure TMain.FormShow(Sender: TObject);
begin
  if (run = False) then
  begin
    // Application.Minimize;
    // ShowWindow(Application.Handle, SW_HIDE); // ����������ͼ��

  end;
  run := True;

end;

procedure TMain.StartServer;
begin

  SessionName := '__guid_session';
  RouleMap := TRouleMap.Create;
  SessionListMap := TSessionList.Create;
  TThSessionClear.Create(false);

  DM := TDM.Create(Self);
  DM.DBManager.DriverDefFileName := db_type;
  DM.DBManager.ConnectionDefFileName := WebApplicationDirectory + config;

end;

procedure TMain.TrayIcon1Click(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_SHOWNOACTIVATE); // ����������ͼ��
  Self.Show;
  Application.BringToFront;
end;

end.
