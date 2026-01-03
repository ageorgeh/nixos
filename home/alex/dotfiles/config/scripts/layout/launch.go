package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"sync"

	"github.com/thiagokokada/hyprland-go"
	"github.com/thiagokokada/hyprland-go/event"
)

type MyHandler struct {
	event.DefaultEventHandler
	onOpen func(w event.OpenWindow)
}

func (e *MyHandler) OpenWindow(w event.OpenWindow) {
	fmt.Println("OpenWindow", w)
	if e.onOpen != nil {
		e.onOpen(w)
	}
}

type AppOptions struct {
	app          string
	title        string
	initialTitle string
	class        string
}

func launchApps(apps map[int][]AppOptions) {
	type launchTask struct {
		window int
		app    AppOptions
	}

	tasks := make([]launchTask, 0)
	for window, list := range apps {
		for _, app := range list {
			if !IsRunning(app) {
				tasks = append(tasks, launchTask{window: window, app: app})
			} else {
				fmt.Printf("%s is already running\n", app.app)
			}
		}
	}

	var wg sync.WaitGroup

	ctx := context.Background()
	go func() {
		e.Subscribe(ctx, &MyHandler{
			onOpen: func(w event.OpenWindow) {
				for i, task := range tasks {
					app := task.app
					if (app.initialTitle != "" && w.Title == app.initialTitle) || IsRunning(app) {
						wg.Done()
						tasks = slices.Delete(tasks, i, i+1)
						fmt.Println("App running: ", app.app)
					}
				}

			},
		}, event.EventOpenWindow)
	}()

	for _, task := range tasks {
		wg.Add(1)
		go func() {
			c.Dispatch("exec " + task.app.app)
			fmt.Println("Launching", "exec "+task.app.app)
		}()
	}

	wg.Wait()
}

func getPid(app string) (int, error) {
	clients, err := c.Clients()
	if err != nil {
		return 0, err
	}

	for _, client := range clients {
		clientAppName, err := AppNameFromPid(client.Pid)
		if err != nil {
			continue
		}
		if clientAppName == getAppName(app) {
			return client.Pid, nil
		}
	}

	return 0, fmt.Errorf("process not found: %s", app)
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
