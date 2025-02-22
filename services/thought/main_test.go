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
		name    string
		input   string
		want    slog.Level
		wantErr error
	}{
		{
			name:    "success",
			input:   "info",
			want:    slog.LevelInfo,
			wantErr: nil,
		},
		{
			name:    "unexpected log level parameter",
			input:   "doesntExist",
			want:    slog.LevelInfo,
			wantErr: errors.New("unexpected log level: doesntExist"),
		},
		{
			name:    "case mismatch",
			input:   "Info",
			want:    slog.LevelInfo,
			wantErr: errors.New("unexpected log level: Info"),
		},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			t.Parallel() // marks each test case as capable of running in parallel with each other
			got, err := validateLogLevel(test.input)
			// Handle errors
			if test.wantErr != nil {
				if err == nil {
					t.Errorf("expected error: %v, but got nil", test.wantErr)
				} else if !errors.Is(err, test.wantErr) && err.Error() != test.wantErr.Error() {
					t.Errorf("expected error: %v, got: %v", test.wantErr, err)
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

func TestLoadParameter(t *testing.T) {
	if err := os.Setenv("TEST_SET", "one"); err != nil {
		t.Error("failed to set environment variable: TEST_SET")
	}
	t.Cleanup(func() {
		os.Unsetenv("TEST_SET")
	})

	t.Parallel()
	tests := []struct {
		name    string
		input   string
		want    string
		wantErr error
	}{
		{
			name:    "unset parameter",
			input:   "TEST_UNSET",
			want:    "",
			wantErr: errors.New("undefined parameter: TEST_UNSET"),
		},
		{
			name:    "set paremeter",
			input:   "TEST_SET",
			want:    "one",
			wantErr: nil,
		},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			t.Parallel()
			got, err := loadParameter(test.input)
			// Handle errors
			if test.wantErr != nil {
				if err == nil {
					t.Errorf("expected error: %v, but got nil", test.wantErr)
				} else if !errors.Is(err, test.wantErr) && err.Error() != test.wantErr.Error() {
					t.Errorf("expected error: %v, got: %v", test.wantErr, err)
				}
			} else if err != nil {
				t.Errorf("unexpected error: %v", err)
			}
			if got != test.want {
				t.Errorf("want: %s. got: '%s", test.want, got)
			}
		})
	}
}
