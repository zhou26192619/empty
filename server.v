module main

import vweb
import sqlite
import json
import strings

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
		data T
		msg string
}

struct Table{
	id int
	name string
	sql_name string
	detail []Column
	version int
}

struct Column{
	name string
	sql_name string
	mold string
}

fn main() {
	vweb.run<App>(port)
}


pub fn (app mut App) index() {
}

fn insert_custom_table(table Table) {
	db := sqlite.connect('test.db')
	detail:=json.encode(table.detail)
	db.exec('insert into custom (name,detail,version) values ("$table.name",\'$detail\',$table.version)')
	db.exec('DROP TABLE IF EXISTS $table.name')
	mut sql := strings.Builder{}
	sql.write('CREATE TABLE IF NOT EXISTS $table.name (id integer PRIMARY KEY autoincrement,') 
	for col in table.detail {
		sql.write('$col.name $col.mold,')
	}
	sql.go_back(1)
	sql.write(')')
	_, sqlcode := db.exec(sql.str())
	println('create table == $sql.str()  ==  $sqlcode')
}

pub fn (app mut App) tables() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	mut result := NetResult<[]Table>{}
	db := sqlite.connect('test.db')
	rows, _ := db.exec('select * from custom')
	println(rows)
	mut tables:=[]Table
	for row in rows {
		detail:= json.decode([]Column, row.vals[3])or{
			return
		}
		table:= Table{
			id:row.vals[0].int(),
			name :row.vals[1],
			sql_name:row.vals[2],
			detail :detail,
			version :row.vals[4].int()
		}
		tables << table
	}
	result.data=tables
	app.vweb.json(json.encode(result))
}

pub fn (app mut App) table_info() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	table_name := app.vweb.form['table']
	db := sqlite.connect('test.db')
	rows, _ := db.exec('select * from $table_name')
	println(rows)
	// mut infos:=[]map[string]string
	// for row in rows {
		
	// }
	app.vweb.json(json.encode(rows))
}

pub fn (app mut App) add_table() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	println(app.vweb.form['data'])
	table:=json.decode(Table,app.vweb.form['data']) or{
		app.vweb.text('shibai')
		return
	}
	insert_custom_table(table)
	app.vweb.text('jieshu')
}

pub fn (app mut App) delete_table() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	table:=app.vweb.form['table']
	db := sqlite.connect('test.db')
	db.exec('delete from custom where name="$table"')
	db.exec('drop table $table;')
	app.vweb.text('jieshu')
}

pub fn (app mut App) add_data() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	table_name:=app.vweb.form['table']
	mut data_str := app.vweb.form['data']
	mut sqlstr:=strings.Builder{}
	sqlstr.write('insert into $table_name (')
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
	println(sqlstr.str())
	db := sqlite.connect('test.db')
	db.exec(sqlstr.str())

	app.vweb.text('jieshu')
}

pub fn (app mut App) delete_data() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	table_name:=app.vweb.form['table']
	mut data_str := app.vweb.form['data']
	mut sqlstr:=strings.Builder{}
	sqlstr.write('insert into $table_name (')
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
	println(sqlstr.str())
	db := sqlite.connect('test.db')
	db.exec(sqlstr.str())

	app.vweb.text('jieshu')
}