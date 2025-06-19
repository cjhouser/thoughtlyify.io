package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
)

func handleThoughts(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		getThoughts(w, r)
	case http.MethodPost:
		postThought(w, r)
	default:
		r.Response.StatusCode = http.StatusMethodNotAllowed
	}
}

func postThought(w http.ResponseWriter, r *http.Request) {
	var m Message

	err := json.NewDecoder(r.Body).Decode(&m)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	conn, err := db.Acquire(context.Background())
	if err != nil {
		slog.Error(err.Error())
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	defer conn.Release()

	sql := fmt.Sprintf("INSERT INTO messages (id, content) VALUES ('%s', '%s')", m.ID, m.Content)
	rows, err := conn.Query(context.Background(), sql)
	if err != nil {
		slog.Error(err.Error())
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	w.WriteHeader(http.StatusOK)
}

func getThoughts(w http.ResponseWriter, r *http.Request) {
	conn, err := db.Acquire(context.Background())
	if err != nil {
		slog.Error(err.Error())
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	defer conn.Release()

	rows, err := conn.Query(context.Background(), "SELECT * FROM messages")
	if err != nil {
		slog.Error(err.Error())
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	ms := []Message{}
	for rows.Next() {
		if err := rows.Err(); err != nil {
			slog.Error(err.Error())
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		m := Message{}
		rows.Scan(&m.ID, &m.Content)
		ms = append(ms, m)
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(ms)
}
