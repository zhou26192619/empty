module main

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
	println('$str')
	tokens :=parse(str)
	parse_json(tokens)
}

fn parse(str string) []Token{
	new_str:= str.trim_space()
	mut tokens := []Token{}
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
				if !(new_str[j].str() in ['0','1','2','3','4','5','6','7','8','9','.']) {
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
	for token in tokens {
		println('tokens.value == ' +token.value)	
	}
	println('tokens.len $tokens.len')
	return tokens
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

fn parse_json(tokens []Token) {
	re,_:=parse_json_object(tokens,0) 
}


fn parse_json_object(tokens []Token,index int) (map[string]voidptr,int) {
	mut token_index:=index
	mut obj:=map[string]voidptr{}
	mut expect_tokens := [ TokenType.str , .end_object]
	mut key:=''
	for ; token_index < tokens.len;{
		temp:= tokens[token_index]
		// println('for obj $token_index == $temp.value')
		token_index++
		match temp.token_type {
			.begin_object {
				v,i:=parse_json_object(tokens,token_index) 
				token_index=i
				obj[key]=&v
				expect_tokens=[.str,.end_object]
			}
			.end_object {
				println('value = $obj')
				return obj,token_index
			}
			.begin_array {
				v,i:=parse_json_array(tokens,token_index)
				token_index=i
				obj[key]=&v
			}
			.str {
				next:= tokens[token_index]
				if next.token_type ==.colon{
					key =temp.value
					expect_tokens=[.colon]
				}else{
					v :=temp.value.clone()
					obj[key]=&v
					expect_tokens=[.comma,.end_object]
				}
			}
			.number {
					v :=temp.value.clone()
					obj[key]=&v
					expect_tokens=[.comma,.end_object]
			}
			.boolean {
					v :=temp.value.clone()
					obj[key]=&v
					expect_tokens=[.comma,.end_object]
			}
			.colon {
				expect_tokens=[ .str , .begin_object , .begin_array , .number , .null , .boolean ]
			}
			.comma {
				expect_tokens=[ .str ]
			}
			else {

			}
		}
	}
	return obj,token_index
}
fn parse_json_array(tokens []Token,index int) ([]voidptr, int){
	mut token_index:=index
	mut obj:=[]voidptr{}
	mut expect_tokens := [ TokenType.str , .begin_array,.begin_object,.number,.boolean,.null]
	for ; token_index < tokens.len;{
		temp:= tokens[token_index]
			// println('for arr $token_index == $temp.value')
		token_index++
			match temp.token_type {
				.begin_object {
					v,i:=parse_json_object(tokens,token_index) 
					token_index=i
					obj << &v
					expect_tokens=[.str,.end_object]
				}
				.end_array{
					println('value = $obj')
					return obj,token_index
				}
				.begin_array {
					v,i:=parse_json_array(tokens,token_index)
					token_index=i
					obj<< &v
				}
				.str {
					v :=temp.value.clone()
					obj << &v
					expect_tokens=[.comma,.end_array]
				}
				.number {
					v :=temp.value.clone()
					obj << &v
					expect_tokens=[.comma,.end_array]
				}
				.boolean {
					v :=temp.value.clone()
					obj << &v
					expect_tokens=[.comma,.end_array]
				}
				.comma {
					expect_tokens=[ .str ]
				}
				else {

				}
			}
		
	}
	return obj,token_index
}