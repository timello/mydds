// Package types is ...
package types

import "context"

type NodeDriver interface {
	PutObject(context.Context, string, Object) error
	GetObject(context.Context, string) (Object, error)
}

type Node struct {
	Name   string
	Driver NodeDriver
}

func NewNode(driver NodeDriver) Node {
	return Node{
		Driver: driver,
	}
}

func (n *Node) PutObject(ctx context.Context, key string, object Object) error {
	return n.Driver.PutObject(ctx, key, object)
}

func (n *Node) GetObject(ctx context.Context, key string) (Object, error) {
	return n.Driver.GetObject(ctx, key)
}
