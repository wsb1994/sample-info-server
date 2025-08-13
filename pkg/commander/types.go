package commander

import "time"

type Commander interface {
	Ping(host string) (PingResult, error)
	GetSystemInfo() (SystemInfo, error)
}

type PingResult struct {
	Successful bool
	Time       time.Duration
}

type SystemInfo struct {
	Hostname  string
	IPAddress string
}

type CommandRequest struct {
	Type    string `json:"type"`              // "ping" or "sysinfo"
	Payload string `json:"payload,omitempty"` // For ping, this is the host
}

type CommandResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data"`
	Error   string      `json:"error,omitempty"`
}
