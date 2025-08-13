package commander

import (
	"net"
	"net/http"
	"os"
	"time"
)

type commander struct{}

func NewCommander() Commander {
	return &commander{}
}

func (c *commander) Ping(host string) (PingResult, error) {
	start := time.Now()

	resp, err := http.Get(host)
	if err != nil {
		return PingResult{Successful: false}, err
	}
	defer resp.Body.Close()

	duration := time.Since(start)
	return PingResult{Successful: true, Time: duration}, nil
}

func (c *commander) GetSystemInfo() (SystemInfo, error) {
	hostname, err := getLocalHostname()
	if err != nil {
		return SystemInfo{}, err
	}

	// Get outbound IP address
	ip, err := getOutboundIP()
	if err != nil {
		return SystemInfo{}, err
	}
	return SystemInfo{
		Hostname:  hostname,
		IPAddress: ip.String(),
	}, nil
}

func getOutboundIP() (net.IP, error) {
    conn, err := net.Dial("tcp", "8.8.8.8:80")
    if err != nil {
        return nil, err
    }
    defer conn.Close()

    localAddr := conn.LocalAddr().(*net.TCPAddr)
    return localAddr.IP, nil
}


func getLocalHostname() (string, error) {
	hostname, err := os.Hostname()
	if err != nil {
		return hostname, err
	}
	return hostname, nil
}
