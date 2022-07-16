// Package s3 implements a S3 node type.
package s3

import (
	"context"
	"fmt"
	"io"
	"strings"

	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/timello/mydds/pkg/types"
)

type NodeDriver struct {
	bucketName string
	client     *s3.Client
}

func NewNodeDriver(client *s3.Client, bucketName string) types.NodeDriver {
	return &NodeDriver{
		client:     client,
		bucketName: bucketName,
	}
}

func (n NodeDriver) PutObject(ctx context.Context, key string, object types.Object) error {
	if n.client == nil {
		return fmt.Errorf("S3NodeDriver.PutObject: client is nil")
	}

	params := &s3.PutObjectInput{
		Bucket: &n.bucketName,
		Key:    &key,
		Body:   strings.NewReader(string(object.Body())),
	}

	_, err := n.client.PutObject(ctx, params)
	if err != nil {
		return fmt.Errorf("S3NodeDriver.PutObject: %v", err)
	}

	return nil
}

func (n NodeDriver) GetObject(ctx context.Context, key string) (types.Object, error) {
	if n.client == nil {
		return nil, fmt.Errorf("S3NodeDriver.GetObject: client is nil")
	}

	params := &s3.GetObjectInput{
		Bucket: &n.bucketName,
		Key:    &key,
	}

	resp, err := n.client.GetObject(ctx, params)
	if err != nil {
		return nil, fmt.Errorf("S3NodeDriver.GetObject: %v", err)
	}

	buf, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("S3NodeDriver.GetObject: %v", err)
	}

	return types.NewObject(key, buf), nil
}
