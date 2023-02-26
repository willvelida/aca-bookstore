package mocks

import "github.com/willvelida/aca-bookstore-api/pkg/models"

var Book = []models.Book{
	{
		ID:     1,
		Title:  "How to avoid a climate disaster",
		Author: "Bill Gates",
		Price:  24.99,
	},
	{
		ID:     2,
		Title:  "My book of tricks",
		Author: "Will Velida",
		Price:  9.99,
	},
}
