// Package types is ...
package types

type Node interface {
	PutObject(key string, object Object) error
	GetObject(key string) (Object, error)
}
