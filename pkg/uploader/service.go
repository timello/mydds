// Package uploader is...
package uploader

import (
	"github.com/timello/mydds/pkg/types"
)

type Service interface {
	// Upload uploads an object to the available nodes and returns the
	// hash of the uploaded object.
	Upload(types.Object) string
}

type service struct {
	Nodes []types.Node
}
