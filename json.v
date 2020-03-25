module main

fn main() {
	str:='
	{
		"adsd":-253543,
		"arr":[
			{
				"tt":"283,:[]2{9}741","show":false}
		],
		"hhh":{
			"name":"zhan[gsan"
		}
	}'

	parse(str)
}

enum TokenType {
	null number str  begin_object end_object begin_array end_array boolean colon comma docment
} 

struct Token{
	token_type TokenType
	value string
}

fn parse(str string) {
	new_str:= str.trim_space()
	mut result:=[]Token
	for i:=0; i<new_str.len;i++ {
		s:=new_str[i].str().trim_space()
		if s=='"' {
			temp:= new_str.substr(i+1,new_str.index_after('"',i+1))
			i += temp.len+1
			tt:= TokenType{
				token_type:TokenType.str,
				value:temp
			}
			result << tt
		}
		else if s in '{' {
			result << TokenType{
				token_type:TokenType.begin_object,
				value:s
			}
		}
		else if s in '}' {
			result << TokenType{
				token_type:TokenType.end_object,
				value:s
			}
		}
		else if s in '[' {
			result << TokenType{
				token_type:TokenType.begin_array,
				value:s
			}
		}
		else if s in ['{','}','[',']',',',':'] {
			result << s
		}
		else if s=='f' {
			result << parse_constont_value(i,'false',new_str)
			i+=4
		}
		else if s=='t' {
			result << parse_constont_value(i,'true',new_str)
			i+=3
		}
		else if s=='n' {
			result << parse_constont_value(i,'null',new_str)
			i+=3
		}
		else if s in ['-','0','1','2','3','4','5','6','7','8','9'] {
			mut j:=i+1
			for ;; j++ {
				if ! new_str[j].str() in ['0','1','2','3','4','5','6','7','8','9']{
					break
				}
			}
			result << new_str.substr(i,j)
			i=j-1
		}
		else {

		}
	}
	println(result)
}

fn parse_constont_value(start int ,target string, sourse string) string {
	temp:= sourse.substr(start,start+target.len)
	if temp==target{
		 return target
	}else{
		panic('json err  $temp')
	}
}