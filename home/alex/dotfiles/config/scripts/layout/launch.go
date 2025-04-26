package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/thiagokokada/hyprland-go/event"
)

func launchApps(apps map[int][]string) {
	for window, list := range apps {
		for _, app := range list {
			if isRunning(app) {
				fmt.Printf("%s is already running\n", app)
				continue
			}

			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
			done := make(chan struct{}) // channel to signal window opened

			go func(appName string) {
				go func() {
					e.Subscribe(ctx, &ev{
						onOpen: func(w event.OpenWindow) {
							if isRunning(appName) {
								close(done) // window opened, signal done
							}
						},
					}, event.EventOpenWindow)
				}()

				c.Dispatch("focusmonitor " + fmt.Sprint(window))
				c.Dispatch("exec " + appName)
				fmt.Println("Launching", appName)
			}(app)

			select {
			case <-done:
				fmt.Printf("%s launched successfully\n", app)
			case <-ctx.Done():
				fmt.Printf("Timeout launching %s\n", app)
			}

			cancel() // cancel the subscription ctx manually after select
		}
	}
}

func isRunning(app string) bool {
	clients, err := c.Clients()
	if err != nil {
		return false
	}
	for _, client := range clients {
		clientAppName, err := AppNameFromPid(client.Pid)
		if err != nil {
			continue
		}
		if clientAppName == getAppName(app) {
			return true
		}

	}
	return false
}

func AppNameFromPid(pid int) (string, error) {
	cmdlinePath := fmt.Sprintf("/proc/%d/cmdline", pid)
	cmdlineBytes, err := os.ReadFile(cmdlinePath)
	if err != nil {
		return "", err
	}
	appName := getAppName(string(cmdlineBytes))
	if appName == "" {
		return "", fmt.Errorf("could not get app name from pid %d", pid)
	}
	return appName, nil
}

func getAppName(app string) string {
	// First, replace null bytes (from /proc/cmdline) with spaces
	app = strings.ReplaceAll(app, "\x00", " ")
	// Trim leading/trailing spaces (just in case)
	app = strings.TrimSpace(app)
	// If there's a space, cut at first space (only keep command)
	if idx := strings.Index(app, " "); idx != -1 {
		app = app[:idx]
	}
	// If there's a slash, take only the basename
	if strings.Contains(app, "/") {
		app = filepath.Base(app)
	}
	// This is nixos specific
	app = strings.TrimPrefix(app, ".")
	app = strings.TrimSuffix(app, "-wrapped")

	// Final cleanup: trim again (paranoia, but cheap)
	return strings.TrimSpace(app)
}
