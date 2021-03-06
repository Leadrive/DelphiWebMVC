unit IndexController;

interface

uses
  System.SysUtils, System.Classes, superobject, View, BaseController;

type
  TIndexController = class(TBaseController)
  public
    procedure Index(num: Double);
    procedure check;
    procedure verifycode;
    procedure setdata;
    procedure home(value1, value2, value3, value4, value5: string);
  end;

implementation

uses
  UsersService, UsersInterface, uGlobal;


{ TIndexController }

procedure TIndexController.check;
var
  s: string;
  map, ret: ISuperObject;
  code: string;
  user_service: IUsersInterface;
begin
  user_service := TUsersService.Create(View.Db);
  with view do
  begin
//    ret := Db.MYSQL.FindFirst('tb_users');  //mysql 使用
//    s := ret.AsString;
    map := SO();
    map.S['username'] := Input('username');
    map.S['pwd'] := Input('pwd');
    code := Input('vcode');
    if code.ToLower = SessionGet('vcode').ToLower then
    begin

      ret := user_service.checkuser(map);
      if ret <> nil then
      begin
        SessionSet('user', ret.AsString);
        Success(0, '登录成功');
      end
      else
      begin
        Fail(-1, '登录失败,请检查用户名密码');
      end;
    end
    else
    begin
      Fail(-1, '验证码错误');
    end;
  end;
end;

procedure TIndexController.home(value1, value2, value3, value4, value5: string);
var
  s: string;
begin
//http://localhost:8004/home/ddd/12/32/eee/333.html
//http://localhost:8004/home/ddd/12/32/eee/333
//http://localhost:8004/home/ddd/12/32/eee/333?name=admin
 //伪静态及Rest风格
  with view do
  begin
    s := InputByIndex(2);
    s := Input('name');
    ShowText(s + ' ' + value1 + ' ' + value2 + ' ' + value3 + ' ' + value4 + ' ' + value5);
  end;
end;

procedure TIndexController.Index(num: Double);
var
  s: string;
  jo: ISuperObject;
begin
  with View do
  begin
    Global.test:='ok'; //全局变量使用
    SessionRemove('user');
//    jo := SO();
//    jo.S['msg'] := '你好呀';
//    RedisSetKeyJSON('name', jo);
//    RedisRemove('name');
//    s := RedisGetKeyJSON('name').AsString;
//    RedisSetKeyText('sex', '男');
//    s := RedisGetKeyText('sex');
    ShowHTML('login');
  end;
end;

procedure TIndexController.setdata;
var
  s: string;
begin
  s := Request.Content;
end;

procedure TIndexController.verifycode;
var
  code: string;
  i: integer;
const
  str = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
begin

  with view do
  begin
    for i := 0 to 3 do
    begin
      code := code + Copy(str, Random(Length(str)), 1);
    end;
    SessionSet('vcode', code);
    if Length(code) <> 4 then
    begin
      ShowText('error');
    end
    else
      ShowVerifyCode(code);
  end;
end;

end.

