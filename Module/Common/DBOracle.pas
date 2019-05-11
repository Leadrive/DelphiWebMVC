{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       ��Ȩ���� (C) 2019 ����ӭ(PRSoft)                }
{                                                       }
{*******************************************************}
unit DBOracle;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, superobject, DBBase, Data.DB;

type
  TDBOracle = class(TDBBase)
  public
    function FindFirst(tablename: string; where: string = ''): ISuperObject; overload; override;
    function QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject; override;
    procedure StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant); overload;
  end;

implementation

{ TDBOracle }

function TDBOracle.FindFirst(tablename: string; where: string = ''): ISuperObject;
var
  sql: string;
begin
  Result := nil;
  if (Trim(tablename) = '') then
    Exit;
  if Fields = '' then
    Fields := '*';
  sql := 'select ' + Fields + ' from ' + tablename + ' where 1=1 ' + where;
  sql := 'select * from (' + sql + ') where rownum=1';
  Result := QueryFirst(sql);
end;

function TDBOracle.QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject;
var
  CDS: TFDQuery;
  sql: string;
begin
  Result := nil;
  if (not TryConnDB) or (Trim(select) = '') or (Trim(from) = '') then
    Exit;
  if Fields = '' then
    Fields := '*';
  if Trim(order) <> '' then
    order := 'order by ' + Trim(order);
  CDS := TFDQuery.Create(nil);
  try
    try
      CDS.Connection := condb;
      sql := 'select count(1) as N from ' + from;
      sql := filterSQL(sql);
      CDS.Open(sql);
      count := CDS.FieldByName('N').AsInteger;
      CDS.Close;
      sql := 'select A.*,rownum rn from(select ' + Fields + ' from ' + from + ')';
      sql := 'select * from (' + sql + ') where rn between ' + IntToStr(pagesize * pageindex) + ' and ' + IntToStr(pagesize);

      Result := Query(sql);
    except
      on e: Exception do
      begin
        DBlog(e.ToString);
        Result := nil;
      end;

    end;
  finally
    FreeAndNil(CDS);
  end;

end;

procedure TDBOracle.StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant);
begin
  with StoredProc.Params.Add do
  begin
    DisplayName := DisplayName_;
    Name := DisplayName_;
    DataType := DataType_;
    Value := Value_;
    ParamType := ParamType_;
  end;
end;

end.

