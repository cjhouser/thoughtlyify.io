package main

import (
	"context"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"strconv"

	"github.com/jackc/pgx/v5/pgxpool"
)

var db *pgxpool.Pool

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

func validateIPv6Address(address string) (net.IP, error) {
	ip := net.ParseIP(address)
	if ip == nil || ip.To4() != nil {
		return nil, fmt.Errorf("invalid ipv6 address: %s", address)
	}
	return ip, nil
}

func validatePort(port string) (int, error) {
	portNumber, err := strconv.Atoi(port)
	if err != nil || (portNumber < 0 || portNumber > 65535) {
		return -1, fmt.Errorf("invalid port: %s", port)
	}
	return portNumber, nil
}

func run() (err error) {
	level := new(slog.LevelVar)
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: level,
		ReplaceAttr: func(groups []string, a slog.Attr) slog.Attr {
			if a.Key == slog.LevelKey {
				switch a.Value.String() {
				case "DEBUG":
					a.Value = slog.StringValue("D")
				case "INFO":
					a.Value = slog.StringValue("I")
				case "WARN":
					a.Value = slog.StringValue("W")
				case "ERROR":
					a.Value = slog.StringValue("E")
				default:
					// Unknown level
					a.Value = slog.StringValue("U")
				}
				return a
			}
			if a.Key == slog.TimeKey {
				t := a.Value.Time()
				a.Value = slog.StringValue(t.Format("2006-01-02T15:04:05.00000"))
				return a
			}
			return a
		},
	})))

	// Define parameters and default values
	parameters := map[string]string{
		"ADDRESS":           "",
		"PORT":              "",
		"LOG_LEVEL":         "",
		"POSTGRES_URL":      "",
		"POSTGRES_DATABASE": "",
		"POSTGRES_USER":     "",
		"POSTGRES_PORT":     "",
		"POSTGRES_PASSWORD": "",
	}

	// Load parameters from environment variables and use default value defined
	for parameter := range parameters {
		value, err := loadParameter(parameter)
		if err != nil {
			return err
		}
		parameters[parameter] = value
	}

	// Validate parameters
	logLevel, err := validateLogLevel(parameters["LOG_LEVEL"])
	if err != nil {
		return err
	}

	address, err := validateIPv6Address(parameters["ADDRESS"])
	if err != nil {
		return err
	}

	port, err := validatePort(parameters["PORT"])
	if err != nil {
		return err
	}

	// Set up configuration
	level.Set(logLevel)
	socket := fmt.Sprintf("[%s]:%d", address.String(), port)
	server := &http.Server{
		Addr:    socket,
		Handler: nil,
	}

	// Connect to the database
	dsn := fmt.Sprintf(
		"postgresql://%s:%s@%s:%s/%s",
		parameters["POSTGRES_USER"],
		parameters["POSTGRES_PASSWORD"],
		parameters["POSTGRES_URL"],
		parameters["POSTGRES_PORT"],
		parameters["POSTGRES_DATABASE"],
	)
	db, err = pgxpool.New(context.Background(), dsn)
	if err != nil {
		return err
	}

	// Endpoints
	http.HandleFunc("/thoughts", handleThoughts)

	// Do the server thing
	slog.Info(fmt.Sprintf("listening on %s", socket))
	err = server.ListenAndServe()
	return err
}

func main() {
	if err := run(); err != nil {
		slog.Error(err.Error())
		os.Exit(166)
	}
}
