package mocks

import "net/http"

// Client is the mock client
type Client struct {
	GetFunc func(url string) (resp *http.Response, err error)
}

var (
	GetFuncVar func(url string) (resp *http.Response, err error)
)

func (m *Client) Get(url string) (resp *http.Response, err error) {
	return GetFuncVar(url)
}
