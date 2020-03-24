module main

import vweb
import sqlite
import json
import strings

const (
	port = 8082
	BASE_TABLE = 'custom'
)

pub struct App {
pub mut:
	vweb vweb.Context // TODO embed
	cnt int
}
pub fn (app mut App) reset() {

}
pub fn (app mut App) init() {

}

struct NetResult<T>{
	mut:
		code int
		msg string
		data T
}

struct NetArrResult<T>{
	mut:
		code int
		msg string
		data []T
}

struct Table{
	id int
	name string
	version int
	mut : 
		detail []Column
		sql_name string [ignore]
}

struct Column{
	name string
	mold string
	mode string
	parent string
	mut :
		sql_name string [ignore]
}
struct Data{
	id string
	table string
	data string
}

fn main() {
	vweb.run<App>(port)
}


pub fn (app mut App) index() {
}

fn insert_custom_table(table Table) {
	detail:=json.encode(table.detail)
	db := sqlite.connect('test.db')
	//check if the table exists
	rows,_:=db.exec("select * from $BASE_TABLE  where sql_name=='$table.sql_name'")
	println('check if the table exists == $rows')
	if rows.len>0 {
		_,code:=db.exec("update $BASE_TABLE set name='$table.name',sql_name='$table.sql_name',detail='$detail',version=$table.version where id=${rows[0].vals[0]}")
		db.exec('DROP TABLE IF EXISTS $table.sql_name')
		if code ==101 {
			create_table(table)
		}
	}else{
		_,code:=db.exec("insert into $BASE_TABLE (name,sql_name,detail,version) values ('$table.name','$table.sql_name','$detail',$table.version)")
		if code ==101 {
			create_table(table)
		}
	}
}

pub fn create_table(table Table){
	mut sql := strings.Builder{}
	sql.write('CREATE TABLE IF NOT EXISTS "$table.sql_name" (id integer PRIMARY KEY autoincrement,') 
	for col in table.detail {
		sql.write('"$col.sql_name" $col.mold,')
	}
	sql.go_back(1)
	sql.write(')')
	db := sqlite.connect('test.db')
	_, sqlcode := db.exec(sql.str())
	println('create table == $sql.str()  ==  $sqlcode')
}

pub fn (app mut App) tables() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	mut result := NetArrResult<Table>{}
	db := sqlite.connect('test.db')
	rows, _ := db.exec('select * from custom')
	mut tables:=[]Table
	for row in rows {
		detail:= json.decode([]Column, row.vals[3])or{
			return
		}
		table:= Table{
			id:row.vals[0].int(),
			sql_name:row.vals[1],
			name :row.vals[2],
			detail :detail,
			version :row.vals[4].int()
		}
		tables << table
	}
	result.data=tables
	app.vweb.json(json.encode(result))
}

pub fn (app mut App) add_table() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	println('add_table start == '+app.vweb.req.data)
	mut table:=json.decode(Table,app.vweb.req.data) or{
		app.vweb.text('shibai')
		return
	}
	// table.sql_name=base64.encode(table.name)
	table.sql_name=table.name
	for i,col in table.detail {
		// table.detail[i].sql_name=base64.encode(col.name)
		table.detail[i].sql_name=col.name
	}
	println('encode == '+json.encode(table))
	insert_custom_table(table)
	app.vweb.text('jieshu')
}

pub fn (app mut App) delete_table() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	table:=app.vweb.req.data
	println('delete table == $table')
	db := sqlite.connect('test.db')
	_,code:=db.exec('delete from custom where sql_name="$table"')
	db.exec('drop table "$table";')
	println('delete from custom where sql_name="$table" == $code')
	app.vweb.text('jieshu')
}

pub fn (app mut App) list_data() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	table_name := app.vweb.req.data
	db := sqlite.connect('test.db')
	rows, code := db.exec('select * from "$table_name"')
	println('select * from "$table_name" == $code')
	app.vweb.json(json.encode(rows))
}

pub fn (app mut App) add_data() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	mut data_str := app.vweb.req.data
	println(data_str)
	// data:=json.decode(Data,data_str) or{
	// 	app.vweb.text('shibai')
	// 	return
	// }
	// println(json.encode(data))
	start :=data_str.index('"table":"') or {
		return
	}
	end:=data_str.index('",') or{
		return 
	}
	table_name:=data_str.substr(start+9,end)
	data_start :=data_str.index('"data":') or {
		return
	}
	data_str=data_str.substr(data_start+7,data_str.len-1)
	mut sqlstr:=strings.Builder{}
	sqlstr.write('insert into "$table_name" (')
	data_str = data_str.trim_left('{')
	data_str = data_str.trim_right('}')
	items := data_str.split(',')
	for item in items{
		info :=item.split(':')
		key:=info[0]
		sqlstr.write('$key,')
	}
	sqlstr.go_back(1)
	sqlstr.write(') values (')
	for item in items{
		info :=item.split(':')
		key:=info[1]
		sqlstr.write('$key,')
	}
	sqlstr.go_back(1)
	sqlstr.write(');')
	db := sqlite.connect('test.db')
	_,code:=db.exec(sqlstr.str())
	println(sqlstr.str() +' == $code')
	app.vweb.text('jieshu')
}

pub fn (app mut App) delete_data() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	data_str:=app.vweb.req.data
	println(data_str)
	mut table:=''
	mut id:=''
	ss:=data_str.split(',')
	for s in ss {
		ts:=s.split(':')
		if ts[0].contains('id') {
			id=ts[1]
		}
		if ts[0].contains('table') {
			table=ts[1]
		}
	}
	db := sqlite.connect('test.db')
	_,code:=db.exec('delete from "$table" where id=$id')
	println('delete from "$table" where id=$id == $code')
	app.vweb.text('jieshu')
}