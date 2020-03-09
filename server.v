module main

import vweb

import net.http
import sqlite

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
	db := sqlite.connect('file:test:')
	users, mut code := db.exec('select * from user')
	println('user = $users , code = $code')

	// app.vweb.handle_static('.')
}

pub fn (app mut App) json_endpoint() {
	app.vweb.json('{"a": 3}')
}

pub fn (app mut App) index() {
	app.cnt++
	app.vweb.text('ssss')
}

pub fn (app mut App) reset() {
}

pub fn (app mut App) text() {
	app.vweb.text('Hello world')
}

pub fn (app mut App) cookie() {
	app.vweb.set_cookie('cookie', 'test')
	app.vweb.text('Headers: $app.vweb.headers')
}