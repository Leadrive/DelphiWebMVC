{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       ��Ȩ���� (C) 2019 ����ӭ(PRSoft)                }
{                                                       }
{*******************************************************}
unit DBMSSQL12;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, superobject, DBBase, Data.DB;

type
  TDBMSSQL12 = class(TDBBase)
  public
    function FindFirst(tablename: string; where: string = ''): ISuperObject; overload; override;
    function QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject; override;
    procedure StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant); overload;
  end;

implementation

{ TDBMSSQL }

function TDBMSSQL12.FindFirst(tablename: string; where: string = ''): ISuperObject;
var
  sql: string;
begin
  Result := nil;
  if (Trim(tablename) = '') then
    Exit;
  if Fields = '' then
    Fields := '*';
  sql := 'select top 1 ' + Fields + ' from ' + tablename + ' where 1=1 ' + where;
  Result := QueryFirst(sql);
end;

function TDBMSSQL12.QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject;
var
  CDS: TFDQuery;
  sql: string;
begin
  Result := nil;
  if (not TryConnDB) or (Trim(select) = '') or (Trim(from) = '') then
    Exit;
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
      sql := 'select ' + Trim(select) + ' from ' + Trim(from) + ' ' + Trim(order) + ' offset ' + inttostr(pageindex * pagesize) + ' rows fetch next ' + inttostr(pagesize) + ' rows only ';
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

procedure TDBMSSQL12.StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant);
begin
  with StoredProc.Params.Add do
  begin
    DisplayName := '@' + DisplayName_;
    Name := '@' + DisplayName_;
    DataType := DataType_;
    Value := Value_;
    ParamType := ParamType_;
  end;
end;

end.

