module main

import os
import net
import net.http
import time

type SliderFn fn(a string) ?string
pub fn (stt SliderFn)str() string {
	return 'ssss'
}

struct Slider{
  pub mut:	
  on_value_change SliderFn
  a int
}

fn find(s Slider) {
	println(s)
}

fn main(){

	mut slider:=Slider{}
	// slider.on_value_change=find
	// a:=slider.on_value_change(1,2)
	a:=[1,2,3]
	assert slider.a==1

	server:=net.listen(8081)or{panic(err)}
	for {
		accept:=server.accept() or{panic(err)}
		println(accept.recv(1024*2))
		go cmd()
		accept.close()or{}
	}
	server.close()or{}
}
fn cmd() {
	// result:=os.exec('lsof -i:8080') or {return}
	// ss:=result.output.split(' ')
	// for item in ss {
	// 	tmp:=item.int()
	// 	if tmp!=0 {
	// 	println(tmp)
	// 		break
	// 	}
	// }
	os.system("kill -9 `lsof -i:8080 | awk 'NR==2{print $2}'`")
	s:='cd /home/admin/Z-lib && git pull && yarn install && npm run dev'
	os.system(s)
}