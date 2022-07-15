package main

import "net/http"

func putObject(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("upload"))
}
