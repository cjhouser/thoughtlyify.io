package main

import (
	"fmt"
	"os"
)

const ExitConfigError = 1

func loadParameters(parameters map[string]string) error {
	for expected, fallback := range parameters {
		value := os.Getenv(expected)
		if value != "" {
			parameters[expected] = value
		}
		if fallback == "" {
			return fmt.Errorf("undefined parameter: %s", expected)
		}
	}
	return nil
}

func main() {
	// Define parameters and default values
	parameters := map[string]string{
		"HOST":      "",
		"PORT":      "",
		"LOG_LEVEL": "ERROR",
	}

	// Load parameters from environment variables and use default value defined
	if err := loadParameters(parameters); err != nil {
		os.Exit(ExitConfigError)
	}
}
