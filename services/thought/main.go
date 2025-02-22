package main

import (
	"fmt"
	"log/slog"
	"os"
)

const ExitConfigError = 1

func loadParameters(parameters map[string]string) error {
	for expected := range parameters {
		value, isSet := os.LookupEnv(expected)
		if isSet {
			if value == "" {
				return fmt.Errorf("empty parameter: %s", expected)
			}
			parameters[expected] = value
		} else {
			if parameters[expected] == "" {
				return fmt.Errorf("undefined parameter: %s", expected)
			}
		}
	}
	return nil
}

func validateLogLevel(logLevel string) (slog.Level, error) {
	// Validate and set log level
	switch logLevel {
	case "error":
		return slog.LevelError, nil
	case "info":
		return slog.LevelInfo, nil
	case "debug":
		return slog.LevelDebug, nil
	case "warn":
		return slog.LevelWarn, nil
	default:
		return slog.LevelInfo, fmt.Errorf("unexpected log level: %s", logLevel)
	}
}

func main() {
	logOptions := &slog.HandlerOptions{
		Level: slog.LevelError,
	}
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, logOptions)))

	// Define parameters and default values
	parameters := map[string]string{
		"HOST":      "",
		"PORT":      "",
		"LOG_LEVEL": "error",
	}

	// Load parameters from environment variables and use default value defined
	if err := loadParameters(parameters); err != nil {
		slog.Error(err.Error())
		os.Exit(ExitConfigError)
	}

	logLevel, err := validateLogLevel(parameters["LOG_LEVEL"])
	if err != nil {
		slog.Error(err.Error())
		os.Exit(ExitConfigError)
	}
	logOptions.Level = logLevel
}
