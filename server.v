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
	println('vweb example')
	vweb.run<App>(port)
}

pub fn (app mut App) init() {
	db := sqlite.connect('test.db')
	rows, code := db.exec('select * from custom')
	for index,row in rows {
		table:= Table{
			name :row.vals[0],
			detail :row.vals[1],
			version :row.vals[2].int()
		}
			println(table)
			columns:=json.decode([]Column,table.detail)or{
				println('table struct wrong')
				return
			}
			println(columns)
			db.exec('DROP TABLE IF EXISTS $table.name')
			mut sql := strings.Builder{}
			sql.write('CREATE TABLE IF NOT EXISTS $table.name (') 
			for col in columns {
				sql.write('$col.name $col.mold,')
			}
			sql.go_back(1)
			sql.write(')')
			_, sqlcode := db.exec(sql.str())
			println('create $sqlcode')
	}
}

pub fn (app mut App) json_endpoint() {
	app.vweb.json('{"a": 3}')
}

pub fn (app mut App) index() {
	app.cnt++
	app.vweb.text('ssss')
}

pub fn (app mut App) text() {
	app.vweb.text('Hello world')
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

struct Column{
	name string
	mold string
}

pub fn (this Column)str() string{
	return '{name:$this.name,mold:$this.mold}'
}
