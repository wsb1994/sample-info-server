package server

import (
	commander "cpinfo/pkg/commander"

	"github.com/labstack/echo/v4"
)

type ServerState struct {
	EchoServer *echo.Echo
	Commander  commander.Commander
}

func NewServerState() *ServerState {

	server := &ServerState{
		EchoServer: echo.New(),
		Commander:  commander.NewCommander(),
	}

	return server
}
