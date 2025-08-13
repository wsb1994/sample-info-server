package server

import (
	"encoding/json"
	"net/http"

	"github.com/labstack/echo/v4"

	commander "cpinfo/pkg/commander"
)

func (e *ServerState) RegisterRoutes() {
	e.EchoServer.GET("/health", e.HealthHandler)
	e.EchoServer.POST("/execute", e.ExecuteHandler)

}

func (e *ServerState) HealthHandler(c echo.Context) error {
	return c.String(http.StatusOK, "Ok!")
}

func (e *ServerState) ExecuteHandler(c echo.Context) error {

	var command commander.CommandRequest
	if err := json.NewDecoder(c.Request().Body).Decode(&command); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid JSON"})
	}
	switch command.Type {
	case "ping":
		return e.handlePing(c, command.Payload)
	case "sysinfo":
		return e.handleSysInfo(c)
	default:
		return c.String(http.StatusBadRequest, "unknown command type")
	}
}

func (e *ServerState) handlePing(c echo.Context, host string) error {
	result, err := e.Commander.Ping(host)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, commander.CommandResponse{
			Success: false,
			Data:    nil,
			Error:   err.Error(),
		})
	}
	return c.JSON(http.StatusOK, commander.CommandResponse{
		Success: true,
		Data:    result,
		Error:   "",
	})
}

func (e *ServerState) handleSysInfo(c echo.Context) error {
	result, err := e.Commander.GetSystemInfo()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, commander.CommandResponse{
			Success: false,
			Data:    nil,
			Error:   err.Error(),
		})
	}
	return c.JSON(http.StatusOK, commander.CommandResponse{
		Success: true,
		Data:    result,
		Error:   "",
	})
}
