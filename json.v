module main

__global token_index int
__global tokens []Token

enum TokenType {
	null//null
	number//-,0-9
	str//"
	begin_object //{
	end_object //}
	begin_array //[
	end_array //]
	boolean //f,t
	colon //:
	comma //,
	docment
} 

struct Token{
	token_type TokenType
	value string
}

fn main() {
	str:='
	{
		"adsd":-253.543,"arr":[
			{
				"tt":"283,:[]2{9}741","show":false}
		],
		"sd":"s21"
	}'

	parse(str)
}

fn parse(str string) {
	new_str:= str.trim_space()
	tokens = []
	for i:=0; i<new_str.len;i++ {
		s:=new_str[i].str().trim_space()
		if s=='"' {
			temp:= new_str.substr(i+1,new_str.index_after('"',i+1))
			tokens << Token{
				token_type:.str,
				value:temp
			}
			i += temp.len+1
		}
		else if s == '{' {
			tokens << Token{
				token_type:.begin_object,
				value:s
			}
		}
		else if s == '}' {
			tokens << Token{
				token_type:.end_object,
				value:s
			}
		}
		else if s == '[' {
			tokens << Token{
				token_type:.begin_array,
				value:s
			}
		}
		else if s == ']' {
			tokens << Token{
				token_type:.end_array,
				value:s
			}
		}
		else if s == ',' {
			tokens << Token{
				token_type:.comma,
				value:s
			}
		}
		else if s == ':' {
			tokens << Token{
				token_type:.colon,
				value:s
			}
		}
		else if s == 'f'{
			tokens << Token{
				token_type:.boolean,
				value:parse_constont_value(i,'false',new_str)
			}
			i+=4
		}
		else if s == 't' {
			tokens << Token{
				token_type:.boolean,
				value:parse_constont_value(i,'true',new_str)
			}
			i+=3
		}
		else if s=='n' {
			tokens << Token{
				token_type:.null,
				value:parse_constont_value(i,'null',new_str)
			}
			i+=3
		}
		else if s in ['-','0','1','2','3','4','5','6','7','8','9'] {
			mut j:=i+1
			for ;; j++ {
				if ! new_str[j].str() in ['0','1','2','3','4','5','6','7','8','9','.']{
					break
				}
			}
			tokens << Token{
				token_type:.boolean,
				value:new_str.substr(i,j)
			}
			i=j-1
		}
		else {

		}
	}
	parse_json()
}

fn parse_constont_value(start int ,target string, sourse string) string {
	temp:= sourse.substr(start,start+target.len)
	if temp==target{
		 return target
	}else{
		panic('json err  $temp')
	}
}
fn check_expect_token(token Token,expect []TokenType) bool{
	for item in expect {
		if token.token_type== item{
			return true
		} 
	}
	return false
}

__global result voidptr 

fn parse_json() {
	token_index =0
	println('tokens.len $tokens.len')
	// temp := tokens[0]
	// match temp.token_type {
	// 	.begin_object {
			parse_json_object() 
		// }
		// .begin_array {
		// 	parse_json_array()
		// }
		// else{
		// 	panic('json format err')
		// }
	// }
}


fn parse_json_object() ?map[string]voidptr {
	mut obj:=map[string]voidptr
	mut expect_tokens := [ TokenType.str , .end_object]
	mut key:=''
	for i := token_index; i < tokens.len;{
		temp:= tokens[token_index]
		
		if check_expect_token(temp,expect_tokens) {
			println('for $token_index == $temp.value')
			match temp.token_type {
				.begin_object {
					v:=parse_json_object() 
					obj[key]=&v
					expect_tokens=[.str,.end_object]
				}
				.end_object {
					return obj
				}
				.begin_array {
					parse_json_array()
				}
				.str {
					next:= tokens[token_index]
					if next.token_type ==.colon{
						v :=temp.value.clone()
						obj[key]=&v
						expect_tokens=[.comma,.end_object]
						println('value = $key : $v')
					}else{
						key =temp.value
						expect_tokens=[.colon]
					}
				}
				.number {
					next:= tokens[token_index]
					if next.token_type ==.colon{
						v :=temp.value.clone()
						obj[key]=&v
						expect_tokens=[.comma,.end_object]
						println('value = $key : $v')
					}else{
						key =temp.value
						expect_tokens=[.colon]
					}
				}
				.colon {
					expect_tokens=[ .str , .end_object , .begin_array , .number , .null , .boolean ]
				}
				.colon {
					expect_tokens=[ .str ]
				}
				else {

				}
			}
		}else{
			//error
		}
		token_index++
		i = token_index
	}
	return obj
}
fn parse_json_array() {
}