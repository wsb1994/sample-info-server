package main

import (
	"cpinfo/pkg/server"
)

func main() {

	// Initialize server state
	serverState := server.NewServerState()
	serverState.RegisterRoutes()
	serverState.EchoServer.Logger.Fatal(serverState.EchoServer.Start(":8080"))

}
