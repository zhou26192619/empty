module main

import rand
import math

struct Fund {
	total f32
	step_p f32 //
	valve f32 //
	duration int
	mut: 
	remain f32
	income f32
	points []Point =[]Point{}
}

struct Point {
	time string
	rate f32
	price f32
	mut:
	mete int
}

// struct Stock {
// 	price f32
// 	rates []Point
// }

fn main(){

	for i in 0..1000 {
		simulation()
		println('========= $i =========')
	}
	
}
fn simulation() {
		mut price :=f32(30.0) 
		mut base_price:=price
		mut line := []Point{}
		mut fund:=Fund{
			total:10000
			remain:10000
			step_p:20
			duration: 30
			valve:10
		}
		for i := 0; i < fund.duration; i++ {
		rate:= rand.f32_in_range(-0.1, 0.1)
		price = price + price * rate
		mut p:=Point{
			time:i.str()
			rate:rate
			price:price
		}
		if 100-p.price/base_price*100 >fund.valve {
			mut mete := math.floor(fund.total * fund.step_p/100/p.price)
			if mete<100 {
				mete=100
			}
			if fund.remain - mete * p.price>0 {
				fund.remain =f32(fund.remain - mete * p.price)
				p.mete= int(mete)
				fund.points<<p
			    base_price=p.price
				println("mete=$mete  remain=$fund.remain price=$p.price")
			}
		}
		line << p
	}
	mut count:=0
	for item in fund.points {
		count += item.mete
	}
	total := line[line.len-1].price *count +fund.remain
	println("$total")
}