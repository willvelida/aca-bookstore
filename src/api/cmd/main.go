package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/willvelida/aca-bookstore-api/pkg/handlers"
)

func main() {
	router := mux.NewRouter()

	router.HandleFunc("/books", handlers.GetAllBooks).Methods(http.MethodGet)
	router.HandleFunc("/books/{id}", handlers.GetBook).Methods(http.MethodGet)

	log.Println("API is running")
	http.ListenAndServe(":8080", router)
}
