module main

import os

struct Slider<T> {
  	a T
}

struct User {
	__global: a string
}

fn main(){
	s:=Slider<User>{a:User{}}
	mut tokens := []Slider<User>{}
	tokens << s
	println(tokens)
	mut user:=	User{}
	user.a='1111'
	println(user)
	mut user2:=	User{}
	user2.a='22222'
	println(user)
}