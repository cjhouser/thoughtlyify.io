package main

import (
	"fmt"
	"log/slog"
	"os"
)

const ExitConfigError = 1

func loadParameter(parameter string) (string, error) {
	value, isSet := os.LookupEnv(parameter)
	if !isSet {
		return "", fmt.Errorf("undefined parameter: %s", parameter)
	}
	if value == "" {
		return "", fmt.Errorf("empty parameter: %s", parameter)
	}
	return value, nil
}

func validateLogLevel(logLevel string) (slog.Level, error) {
	// Validate and set log level
	switch logLevel {
	case slog.LevelError.String():
		return slog.LevelError, nil
	case slog.LevelInfo.String():
		return slog.LevelInfo, nil
	case slog.LevelDebug.String():
		return slog.LevelDebug, nil
	case slog.LevelWarn.String():
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
		"LOG_LEVEL": "",
	}

	// Load parameters from environment variables and use default value defined
	for parameter := range parameters {
		value, err := loadParameter(parameter)
		if err != nil {
			slog.Error(err.Error())
			os.Exit(ExitConfigError)
		}
		parameters[parameter] = value
	}

	logLevel, err := validateLogLevel(parameters["LOG_LEVEL"])
	if err != nil {
		slog.Error(err.Error())
		os.Exit(ExitConfigError)
	}
	logOptions.Level = logLevel
}
