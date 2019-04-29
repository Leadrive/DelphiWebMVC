{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       ��Ȩ���� (C) 2019 ����ӭ(PRSoft)                }
{                                                       }
{*******************************************************}
unit DBMSSQL08;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, superobject, DBBase;

type
  TDBMSSQL = class(TDBBase)
  public
    function FindFirst(tablename: string; where: string = ''): ISuperObject; overload; override;
    function QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject; override;
  end;

implementation

{ TDBMSSQL }

function TDBMSSQL.FindFirst(tablename: string; where: string = ''): ISuperObject;
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

function TDBMSSQL.QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject;
var
  CDS: TFDQuery;
  sql: string;
  tmp: string;
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
      if select.Trim = '' then
        select := '*';
      sql := 'select ' + select + ' ' + ',ROW_NUMBER() OVER(ORDER BY ' + order + ') AS RowNo from ' + from;
      sql := 'select * from ' + sql + ' where RowNo between ' + IntToStr(pageindex * pagesize) + ' and ' + IntToStr(pageindex * pagesize + pagesize);
      Result := Query(sql);
      PageKey := '';
    except
      on e: Exception do
      begin
        DBlog(e.ToString);
        Result := nil;
      end;

    end;
  finally
    CDS.Free;
    //FreeAndNil(CDS);
  end;

end;

end.

