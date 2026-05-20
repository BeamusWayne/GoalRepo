package main

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"
)

func main() {
	var input []byte
	var err error

	switch len(os.Args) {
	case 1:
		input, err = io.ReadAll(os.Stdin)
	case 2:
		input, err = os.ReadFile(os.Args[1])
	default:
		fmt.Fprintf(os.Stderr, "usage: json-fmt [file.json]\n")
		os.Exit(1)
	}
	if err != nil {
		fmt.Fprintf(os.Stderr, "error reading input: %v\n", err)
		os.Exit(1)
	}

	raw := strings.TrimSpace(string(input))
	if len(raw) == 0 {
		fmt.Fprintf(os.Stderr, "error: empty input\n")
		os.Exit(1)
	}

	dec := json.NewDecoder(strings.NewReader(raw))
	var val any
	if err := dec.Decode(&val); err != nil {
		reportJSONError(raw, err)
		os.Exit(1)
	}

	// Reject trailing non-whitespace after the first valid value.
	rest, _ := io.ReadAll(dec.Buffered())
	rem := strings.TrimSpace(string(rest))
	if rem != "" && !json.Valid([]byte(rem)) {
		dec2 := json.NewDecoder(strings.NewReader(rem))
		if err := dec2.Decode(new(any)); err != nil {
			fmt.Fprintf(os.Stderr, "error: trailing data after valid JSON\n")
			os.Exit(1)
		}
	}

	formatted, err := json.MarshalIndent(val, "", "  ")
	if err != nil {
		fmt.Fprintf(os.Stderr, "error formatting: %v\n", err)
		os.Exit(1)
	}
	fmt.Println(string(formatted))
}

// reportJSONError prints a human-readable error with a snippet.
func reportJSONError(raw string, err error) {
	jsErr, ok := err.(*json.SyntaxError)
	if !ok {
		fmt.Fprintf(os.Stderr, "invalid JSON: %v\n", err)
		return
	}
	offset := int(jsErr.Offset)
	line, col := lineCol(raw, offset)
	fmt.Fprintf(os.Stderr, "invalid JSON at line %d, column %d: %v\n", line, col, jsErr)
	start := max(0, offset-20)
	end := min(len(raw), offset+20)
	snippet := raw[start:end]
	fmt.Fprintf(os.Stderr, "  near: ...%s...\n", snippet)
	marker := strings.Repeat(" ", min(20, offset-start)) + "^"
	fmt.Fprintf(os.Stderr, "       %s\n", marker)
}

func lineCol(s string, offset int) (line, col int) {
	line = 1
	col = 1
	for i := 0; i < offset && i < len(s); i++ {
		if s[i] == '\n' {
			line++
			col = 1
		} else {
			col++
		}
	}
	return
}
