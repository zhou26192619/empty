module main

import vweb
import sqlite
import json
import strings
import encoding.base64
import net.urllib

const (
	port = 8082
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

fn main() {
	vweb.run<App>(port)
}


pub fn (app mut App) index() {
}

fn insert_custom_table(table Table) {
	detail:=json.encode(table.detail)
	db := sqlite.connect('test.db')
	_ ,code:= db.exec("insert into custom (name,sql_name,detail,version) values ('$table.name','$table.sql_name','$detail',$table.version)")
	println('insert into custom == $code')
	db.exec('DROP TABLE IF EXISTS $table.sql_name')
	mut sql := strings.Builder{}
	sql.write('CREATE TABLE IF NOT EXISTS "$table.sql_name" (id integer PRIMARY KEY autoincrement,') 
	for col in table.detail {
		sql.write('"$col.sql_name" $col.mold,')
	}
	sql.go_back(1)
	sql.write(')')
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
	println('add_table start =='+app.vweb.form['data'] +' == '+app.vweb.req.data)
	mut table:=json.decode(Table,app.vweb.form['data']) or{
		app.vweb.text('shibai')
		return
	}
	table.sql_name=base64.encode(table.name)
	for i,col in table.detail {
		table.detail[i].sql_name=base64.encode(col.name)
	}
	insert_custom_table(table)
	app.vweb.text('jieshu')
}

pub fn (app mut App) delete_table() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	table:=app.vweb.form['table']
	db := sqlite.connect('test.db')
	db.exec('delete from custom where sql_name="$table"')
	db.exec('drop table "$table";')
	app.vweb.text('jieshu')
}

pub fn (app mut App) list_data() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	table_name := app.vweb.form['table']
	db := sqlite.connect('test.db')
	rows, _ := db.exec('select * from "$table_name"')
	println(rows)
	// mut infos:=[]map[string]string
	// for row in rows {
		
	// }
	app.vweb.json(json.encode(rows))
}

pub fn (app mut App) add_data() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	table_name:=app.vweb.form['table']
	mut data_str := app.vweb.form['data']
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
	table:=app.vweb.form['table']
	id:=app.vweb.form['id']
	db := sqlite.connect('test.db')
	_,code:=db.exec('delete from "$table" where id=$id')
	println('delete from "$table" where id=$id == $code')
	app.vweb.text('jieshu')
}