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
pub fn (app mut App) add_table() {
	app.vweb.add_header('Access-Control-Allow-Origin' , '*')
	println(app.vweb.form['data'])
	table:=json.decode(TableOop,app.vweb.form['data']) or{
		app.vweb.text('shibai')
		return
	}
	insert_custom_table(table)
	app.vweb.text('jieshu')
}
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

struct Column{
	name string
	mold string
}

pub fn (this Column)str() string{
	return '{name:$this.name,mold:$this.mold}'
}
