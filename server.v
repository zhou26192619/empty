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

fn main() {
	vweb.run<App>(port)
}

pub fn (app mut App) init() {
	
}

pub fn (app mut App) index() {
	app.cnt++

	db := sqlite.connect('test.db')
	rows, _ := db.exec('select * from custom')
	for row in rows {
		table:= Table{
			name :row.vals[0],
			detail :row.vals[1],
			version :row.vals[2].int()
		}
		columns:=json.decode([]Column,table.detail)or{
			println('table struct wrong')
			return
		}
		db.exec('DROP TABLE IF EXISTS $table.name')
		mut sql := strings.Builder{}
		sql.write('CREATE TABLE IF NOT EXISTS $table.name (') 
		for col in columns {
			sql.write('$col.name $col.mold,')
		}
		sql.go_back(1)
		sql.write(')')
		_, sqlcode := db.exec(sql.str())
		println('$sql.str()  ==  $sqlcode')
	}
	app.vweb.text('ssss')
}

fn insert_custom_table(table TableOop) {
	db := sqlite.connect('test.db')
	detail:=json.encode(table.detail)
	db.exec('insert into custom (name,detail,version) values ("$table.name",\'$detail\',$table.version)')
	db.exec('DROP TABLE IF EXISTS $table.name')
	mut sql := strings.Builder{}
	sql.write('CREATE TABLE IF NOT EXISTS $table.name (') 
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
	db := sqlite.connect('test.db')
	rows, _ := db.exec('select * from custom')
	mut tables:=[]TableOop
	for row in rows {
		detail:= json.decode([]Column, row.vals[1])or{
			return
		}
		table:= TableOop{
			name :row.vals[0],
			detail :detail,
			version :row.vals[2].int()
		}
		tables << table
	}
	app.vweb.json(json.encode(tables))
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
	table:=json.decode(TableOop,app.vweb.form['data']) or{
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

// fn endcode_map<T>(s string) ?map[string]T{
// 	mut t:=map[string]T{}
// 	mut res:=s
// 	res=res.trim_left('{')
// 	res=res.trim_right('}')
// 	items := res.split(',')
// 	for item in items{
// 	   info :=	item.replace('"','').split(':')
// 	   t[info[0]] = info[1]
// 	}
// 	println(t)
// 	return t
// }

pub fn (app mut App) reset() {

}

pub fn (app mut App) cookie() {
	app.vweb.set_cookie('cookie', 'test')
	app.vweb.text('Headers: $app.vweb.headers')
}

struct Table{
	name string
	detail string
	version int
}

pub fn (this Table)str() string{
	return '{name:$this.name,detail:$this.detail,version:$this.version}'
}

struct TableOop{
	name string
	detail []Column
	version int
}
pub fn (this TableOop)str() string{
	return '{name:$this.name,detail:$this.detail,version:$this.version}'
}
struct Column{
	name string
	mold string
}

pub fn (this Column)str() string{
	return '{name:$this.name,mold:$this.mold}'
}
