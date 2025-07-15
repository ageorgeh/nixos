package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/thiagokokada/hyprland-go"
	"github.com/thiagokokada/hyprland-go/event"
)

type AppOptions struct {
	app          string
	title        string
	initialTitle string
}

func launchApps(apps map[int][]AppOptions) {
	for window, list := range apps {
		for _, app := range list {

			if IsRunning(app) {
				fmt.Printf("%s is already running\n", app.app)
				continue
			}

			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
			done := make(chan struct{}) // channel to signal window opened

			go func() {
				e.Subscribe(ctx, &ev{
					onOpen: func(w event.OpenWindow) {
						if app.initialTitle != "" && w.Title == app.initialTitle {
							close(done)
						} else if IsRunning(app) {
							close(done) // window opened, signal done
						}

					},
				}, event.EventOpenWindow)
			}()

			c.Dispatch("focusmonitor " + fmt.Sprint(window))
			c.Dispatch("exec " + app.app)
			fmt.Println("Launching", "exec "+app.app)

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

// IsRunning checks if the app is already running
//
// Checks by title first, then app name
func IsRunning(i AppOptions) bool {
	if i.title != "" {
		return TitleRunning(i.title)
	}
	if i.app != "" {
		return AppRunning(i.app)
	}
	return false
}

func AppRunning(app string) bool {
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

func TitleRunning(title string) bool {
	clients, err := c.Clients()
	if err != nil {
		return false
	}
	for _, client := range clients {
		if strings.Contains(client.Title, title) {
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

func ClientFromAddress(address string) (hyprland.Client, error) {
	clients, err := c.Clients()
	if err != nil {
		return hyprland.Client{}, err
	}
	for _, client := range clients {
		if client.Address == address {
			return client, nil
		}
	}
	return hyprland.Client{}, fmt.Errorf("could not find client with address %d", address)
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
