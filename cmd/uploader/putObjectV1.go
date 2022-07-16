package main

import (
	"context"
	"net/http"

	"github.com/aws/aws-sdk-go-v2/config"
	awss3 "github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/timello/mydds/aws/s3"
	"github.com/timello/mydds/pkg/types"
	"github.com/timello/mydds/pkg/uploader"
)

var (
	bucketNames = []string{
		"node1.mydds.tiagomello.com",
		"node2.mydds.tiagomello.com",
	}
)

func putObject(w http.ResponseWriter, r *http.Request) {

	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	client := awss3.NewFromConfig(cfg)

	nodes := make([]types.Node, len(bucketNames))

	for i, bucketName := range bucketNames {
		nodeDriver := s3.NewNodeDriver(client, bucketName)
		nodes[i] = types.Node{
			Name:   bucketName,
			Driver: nodeDriver,
		}
	}

	service := uploader.NewService(nodes)

	object := types.NewObject("test", []byte("test"))
	ctx := context.Background()
	token, err := service.Upload(ctx, "test", object)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
		return
	}
	w.Write([]byte(token))
}
