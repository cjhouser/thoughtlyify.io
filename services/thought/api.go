package main

import (
	"context"
	"log/slog"
	"net/http"
)

func getThoughts(w http.ResponseWriter, r *http.Request) {
	conn, err := db.Acquire(context.Background())
	if err != nil {
		slog.Error(err.Error())
		r.Response.StatusCode = http.StatusInternalServerError
	}
	defer conn.Release()
	rows, err := conn.Query(context.Background(), "SELECT * FROM thought")
	if err != nil {
		slog.Error(err.Error())
		r.Response.StatusCode = http.StatusInternalServerError
	}
	defer rows.Close()
	r.Response.StatusCode = http.StatusOK
}
