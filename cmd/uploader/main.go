package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	httpAddress = ":8080"

	rpcDurations = prometheus.NewSummaryVec(
		prometheus.SummaryOpts{},
		[]string{"uploader"},
	)
)

func main() {
	router := mux.NewRouter().StrictSlash(true)

	router.HandleFunc("/health", getHealth)

	router.Handle("/metrics", promhttp.HandlerFor(
		prometheus.DefaultGatherer,
		promhttp.HandlerOpts{
			EnableOpenMetrics: true,
		},
	))

	router.HandleFunc("/", putObject).Methods("PUT")

	log.Fatal(http.ListenAndServe(httpAddress, router))
}

func getHealth(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}
