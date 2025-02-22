package main

import (
	"errors"
	"log/slog"
	"os"
	"testing"
)

func TestValidateLogLevel(t *testing.T) {
	t.Parallel() // marks test as capable of running in parallel with other tests
	tests := []struct {
		name          string
		input         string
		want          slog.Level
		expectedError error
	}{
		{
			name:          "success",
			input:         "info",
			want:          slog.LevelInfo,
			expectedError: nil,
		},
		{
			name:          "unexpected log level parameter",
			input:         "doesntExist",
			want:          slog.LevelInfo,
			expectedError: errors.New("unexpected log level: doesntExist"),
		},
		{
			name:          "case mismatch",
			input:         "Info",
			want:          slog.LevelInfo,
			expectedError: errors.New("unexpected log level: Info"),
		},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			t.Parallel() // marks each test case as capable of running in parallel with each other
			got, err := validateLogLevel(test.input)
			// Handle errors
			if test.expectedError != nil {
				if err == nil {
					t.Errorf("expected error: %v, but got nil", test.expectedError)
				} else if !errors.Is(err, test.expectedError) && err.Error() != test.expectedError.Error() {
					t.Errorf("expected error: %v, got: %v", test.expectedError, err)
				}
			} else if err != nil {
				t.Errorf("unexpected error: %v", err)
			}
			// Check result
			if test.want != got {
				t.Errorf("want %v, got %v", test.want, got)
			}
		})
	}
}

func TestLoadParameters(t *testing.T) {
	if err := os.Setenv("TEST_SET", "set"); err != nil {
		t.Error("failed to set environment variable: TEST_SET")
	}
	if err := os.Setenv("TEST_SET_EMPTY", ""); err != nil {
		t.Error("failed to set environment variable: TEST_SET_EMPTY")
	}
	t.Parallel()
	tests := []struct {
		name          string
		input         map[string]string
		expectedError error
	}{
		{
			name: "unset parameter without default",
			input: map[string]string{
				"TEST_UNSET": "",
			},
			expectedError: errors.New("undefined parameter: TEST_UNSET"),
		},
		{
			name: "unset parameter with default",
			input: map[string]string{
				"TEST_UNSET": "default",
			},
			expectedError: nil,
		},
		{
			name: "set paremeter",
			input: map[string]string{
				"TEST_SET": "",
			},
			expectedError: nil,
		},
		{
			name: "set empty parameter with default",
			input: map[string]string{
				"TEST_SET_EMPTY": "default",
			},
			expectedError: errors.New("empty parameter: TEST_SET_EMPTY"),
		},
		{
			name: "set empty parameter without default",
			input: map[string]string{
				"TEST_SET_EMPTY": "",
			},
			expectedError: errors.New("empty parameter: TEST_SET_EMPTY"),
		},
		{
			name: "multiple set paremeters",
			input: map[string]string{
				"TEST_UNSET": "default",
				"TEST_SET":   "",
			},
			expectedError: nil,
		},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			t.Parallel()
			err := loadParameters(test.input)
			// Handle errors
			if test.expectedError != nil {
				if err == nil {
					t.Errorf("expected error: %v, but got nil", test.expectedError)
				} else if !errors.Is(err, test.expectedError) && err.Error() != test.expectedError.Error() {
					t.Errorf("expected error: %v, got: %v", test.expectedError, err)
				}
			} else if err != nil {
				t.Errorf("unexpected error: %v", err)
			}
		})
	}
}
