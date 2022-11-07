package ifsc

import "errors"

var (
	ErrInvalidCode          = errors.New("InvalidCode")
	ErrInvalidResponse      = errors.New("IFSC API returned invalid response")
	ErrCustomSubletNotFound = errors.New("custom sublet name not found")
)
