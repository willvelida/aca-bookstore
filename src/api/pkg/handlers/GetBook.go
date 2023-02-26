package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/willvelida/aca-bookstore-api/pkg/mocks"
)

func GetBook(w http.ResponseWriter, r *http.Request) {
	// Read id parameter
	vars := mux.Vars(r)
	id, _ := strconv.Atoi(vars["id"])

	// Iterate over books
	for _, book := range mocks.Book {
		if book.ID == id {
			// If ids are equal, return book
			w.Header().Add("Content-Type", "application/json")
			w.WriteHeader(http.StatusOK)
			json.NewEncoder(w).Encode(book)
			break
		} else {
			// If not, send 404
			w.Header().Add("Content-Type", "application/json")
			w.WriteHeader(http.StatusNotFound)
			json.NewEncoder(w).Encode("Not Found!")
		}
	}
}
