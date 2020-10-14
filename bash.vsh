files:=ls('./')?

for file in files {
	print(file)
	print(' == ')
	println(is_dir(getwd() + '/' + file))
}

println(getwd())