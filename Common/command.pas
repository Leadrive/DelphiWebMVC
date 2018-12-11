unit Command;

interface

uses
  System.SysUtils, System.Variants, RouleItem, System.Rtti, uRouleMap, System.Classes,
  Web.HTTPApp, uConfig, ActiveX, System.DateUtils, SessionList;

var
  RouleMap: TRouleMap = nil; // ·���б�

  SessionListMap: TSessionList = nil;  //session�б�
  SessionName: string;
  rooturl: string;

procedure OpenRoule(web: TWebModule; RouleMap: TRouleMap; var Handled: boolean);

function DeleteDirectory(NowPath: string): Boolean; // ɾ��session����Ŀ¼

procedure log(msg: string);

implementation

uses
  wnMain;

procedure log(msg: string);
var
  log: string;
  tf: TextFile;
  logfile: string;
  fi: THandle;
begin
  if open_log then
  begin

    log := FormatDateTime('yyyy-MM-dd hh:mm:ss', Now) + #13#10 + msg;
    if Main.mmolog.Lines.Count > 1000 then
      main.mmolog.Clear;
    Main.mmolog.Lines.Add(log);
    logfile := WebApplicationDirectory + 'log\';
    if not DirectoryExists(logfile) then
    begin
      CreateDir(logfile);
    end;
    logfile := logfile + 'log_' + FormatDateTime('yyyyMMdd', Now) + '.txt';

    AssignFile(tf, logfile);
    if FileExists(logfile) then
    begin
      Append(tf);
    end
    else
    begin
      fi:=FileCreate(logfile);
      FileClose(fi);
      Rewrite(tf);
    end;
    Writeln(tf, log);
    Flush(tf);
    CloseFile(tf);
  end;
end;

function DateTimeToGMT(const ADate: TDateTime): string;
const
  WEEK: array[1..7] of PChar = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');
  MonthDig: array[1..12] of PChar = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
var
  wWeek, wYear, wMonth, wDay, wHour, wMin, wSec, wMilliSec: Word;
  sWeek, sMonth: string;
begin
  DecodeDateTime(ADate, wYear, wMonth, wDay, wHour, wMin, wSec, wMilliSec);
  wWeek := DayOfWeek(ADate);
  sWeek := WEEK[wWeek];
  sMonth := MonthDig[wMonth];
  Result := Format('%s, %.2d %s %d %.2d:%.2d:%.2d GMT', [sWeek, wDay, sMonth, wYear, wHour, wMin, wSec]);
end;

procedure OpenRoule(web: TWebModule; RouleMap: TRouleMap; var Handled: boolean);
var
  Action: TObject;
  ActoinClass: TRttiType;
  ActionMethod, CreateView, Interceptor: TRttiMethod;
  Response, Request, ActionPath: TRttiProperty;
  url, url1: string;
  item: TRouleItem;
  tmp: string;
  methodname: string;
  k: integer;
  ret: TValue;
  cExt: string;
  typ: string;
begin
  CoInitialize(nil);
  try

    web.Response.ContentEncoding := default_charset;
    web.Response.Server := 'IIS/6.0';
    web.Response.Date := Now;
    url := LowerCase(web.Request.PathInfo);
    k := Pos('.', url);
    if k <= 0 then
    begin
      item := RouleMap.GetRoule(url, url1, methodname);
      if (item <> nil) then
      begin
        //web.Response.ContentType := 'text/html;charset=utf-8';
        ActoinClass := TRttiContext.Create.GetType(item.Action);
        ActionMethod := ActoinClass.GetMethod(methodname);
        CreateView := ActoinClass.GetMethod('CreateView');
        Interceptor := ActoinClass.GetMethod('Interceptor');
        Request := ActoinClass.GetProperty('Request');
        Response := ActoinClass.GetProperty('Response');
        ActionPath := ActoinClass.GetProperty('ActionPath');
        try
          if (ActionMethod <> nil) then
          begin

            Action := item.Action.Create;
            Request.SetValue(Action, web.Request);
            Response.SetValue(Action, web.Response);
            ActionPath.SetValue(Action, item.path);
            CreateView.Invoke(Action, []); // ִ�� Action CreateView ����
            ret := Interceptor.Invoke(Action, []);
            if (not ret.AsBoolean) then
            begin
              ActionMethod.Invoke(Action, []); // ִ�� Action ActionMethod ����
            end;
            FreeAndNil(Action);
          end
          else
          begin
            web.Response.Content := url + '  ��ַ������';
            web.Response.SendResponse;
          end;
        finally
          Handled := true;
          FreeAndNil(ActoinClass);
        end;
      end
      else
      begin
        web.Response.Content := url + '  ��ַ������';
        web.Response.SendResponse;
      end;
    end
    else
    begin
      web.Response.SetCustomHeader('Cache-Control', 'public');
      web.Response.SetCustomHeader('Pragma', 'Pragma');
      tmp := DateTimeToGMT(TTimeZone.local.ToUniversalTime(now()));
      web.Response.SetCustomHeader('Last-Modified', tmp);
      tmp := DateTimeToGMT(TTimeZone.local.ToUniversalTime(now() + 24 * 60 * 60));
      web.Response.SetCustomHeader('Expires', tmp);

      cExt := UpperCase(ExtractFileExt(url));
      if cExt = '.JPG' then
        typ := 'image/jpeg'
      else if cExt = '.PNG' then
        typ := 'image/png'
      else if cExt = '.GIF' then
        typ := 'image/gif'
      else if cExt = '.ICO' then
        typ := 'image/x-icon'
      else if cExt = '.JS' then
        typ := 'application/x-javascript'
      else if cExt = '.CSS' then
        typ := 'text/css';
      if (typ <> '') then
        web.Response.ContentType := typ + ';';// charset='+my_charset;
    end;
  finally
    CoUnInitialize;
  end;

end;

function DeleteDirectory(NowPath: string): Boolean;
var
  search: TSearchRec;
  ret: integer;
  key, s: string;
begin
  if NowPath[Length(NowPath)] <> '\' then
    NowPath := NowPath + '\';
  key := NowPath + '*.txt';
  ret := findFirst(key, faanyfile, search);
  while ret = 0 do
  begin
    s := NowPath + search.name;
    DeleteFile(PWideChar(s));
    ret := FindNext(search);
  end;
  result := True;
end;

end.
