package types

type Object interface {
	Name() string
	Body() []byte
}

type object struct {
	name string
	body []byte
}

func (o *object) Name() string {
	return o.name
}

func (o *object) Body() []byte {
	return o.body
}

func NewObject(name string, body []byte) Object {
	return &object{name: name, body: body}
}
