# Makefile for building Go project for amd64 Linux or Apple Silicon Mac (arm64)

APP_NAME := cpinfo

.PHONY: all linux mac clean

all: linux mac

linux:
	GOOS=linux GOARCH=amd64 go build -o $(APP_NAME)-linux-amd64

mac:
	GOOS=darwin GOARCH=arm64 go build -o $(APP_NAME)-mac-arm64

clean:
	rm -f $(APP_NAME)-linux-amd64 $(APP_NAME)-mac-arm64
