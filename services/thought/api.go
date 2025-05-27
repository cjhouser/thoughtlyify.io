package main

import (
	"log/slog"
	"net/http"
)

func getThoughts(w http.ResponseWriter, r *http.Request) {
	rows, err := pool.Query("SELECT * from thought")
	if err != nil {
		slog.Error(err.Error())
		r.Response.StatusCode = http.StatusInternalServerError
	}
	defer rows.Close()
	rows.NextResultSet()
	r.Response.StatusCode = http.StatusOK
}
