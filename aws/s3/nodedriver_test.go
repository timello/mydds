package s3

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/timello/mydds/pkg/types"
)

type mockS3Client struct {
}

func (m *mockS3Client) PutObject(ctx context.Context, params *s3.PutObjectInput, optFns ...func(*s3.Options)) (*s3.PutObjectOutput, error) {
	return &s3.PutObjectOutput{}, nil
}

func (m *mockS3Client) GetObject(ctx context.Context, params *s3.GetObjectInput, optFns ...func(*s3.Options)) (*s3.GetObjectOutput, error) {
	return &s3.GetObjectOutput{}, nil
}

func TestPutObject(t *testing.T) {
	nodeDriver := NewNodeDriver(&mockS3Client{}, "mybucket")
	nodeDriver.PutObject(context.Background(), "mykey", types.NewObject("myfile", []byte("mydata")))
}
