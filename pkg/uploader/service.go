// Package uploader is...
package uploader

import (
	"context"
	"fmt"

	"github.com/timello/mydds/pkg/types"
)

type Service interface {
	// Upload uploads an object to the available nodes and returns the
	// hash of the uploaded object.
	Upload(context.Context, string, types.Object) (string, error)
}

type service struct {
	Nodes []types.Node
}

func (s *service) Upload(ctx context.Context, key string, obj types.Object) (string, error) {
	var errs []error
	for _, n := range s.Nodes {
		err := n.PutObject(ctx, key, obj)
		if err != nil {
			errs = append(errs, err)
		}
	}

	if len(errs) > 0 {
		return "", fmt.Errorf("uploader: %v", errs)
	}

	return "MY_TOKEN", nil
}

func NewService(nodes []types.Node) Service {
	return &service{
		Nodes: nodes,
	}
}
