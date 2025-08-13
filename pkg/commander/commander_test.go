package commander

import (
    "testing"
)

func Test_GetSystemInfo(t *testing.T) {
    cmdr := NewCommander()
    info, err := cmdr.GetSystemInfo()
    
    if err != nil {
        t.Fatalf("Expected no error, got %v", err)
    }
    
    if info.Hostname == "" {
        t.Error("Expected hostname to be non-empty")
    }
    
    if info.IPAddress == "" {
        t.Error("Expected IP address to be non-empty")
    }
}