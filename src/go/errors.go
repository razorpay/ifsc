package ifsc

import "errors"

var (
	ErrInvalidCode     = errors.New("InvalidCode")
	ErrInvalidResponse = errors.New("IFSC API returned invalid response")
)
