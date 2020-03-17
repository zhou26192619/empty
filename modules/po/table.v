module table

struct Table{
	name string
	detail []Column
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