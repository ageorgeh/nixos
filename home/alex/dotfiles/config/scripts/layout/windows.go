package main

import (
	"fmt"
	"slices"
	"strings"
	"time"

	"github.com/thiagokokada/hyprland-go"
)

const sleepTime = 10 * time.Millisecond

type AllWindowsOptions struct {
	Command  string
	Monitors []int
}

func processAllWindows(args AllWindowsOptions) {
	for _, monitorID := range args.Monitors {
		clients := clientsOnMonitor(monitorID)
		println("Processing all windows on monitor", monitorID)
		for _, client := range clients {
			println("Dispatching command:", args.Command, "for window", client.Title)
			cmd := fmt.Sprintf("%s address:%s", args.Command, client.Address)
			time.Sleep(sleepTime)
			c.Dispatch(cmd)

		}
	}
}

type WindowsInSuccessionOptions struct {
	Command  string
	Monitors []int
	After    *AppOptions
	Apps     []AppOptions
}

func processWindowsInSucession(args WindowsInSuccessionOptions) {
	for _, monitorID := range args.Monitors {
		println("Focusing monitor: ", monitorID)
		c.Dispatch("focusmonitor " + fmt.Sprint(monitorID))

		activeWindow, err := c.ActiveWindow()
		if err != nil {
			println("Error getting active window for monitor", monitorID, ":", err)
			continue // Skip to the next monitor
		}
		// Check if the active window is actually on the focused monitor
		if activeWindow.Monitor != monitorID {
			println("Warning: Active window is not on the focused monitor", monitorID)
			continue // Skip to the next monitor
		}
		var startProcessing bool = args.After == nil
		var prevWindow string = ""
		maxIterations := 50 // Limit iterations per monitor

		for range maxIterations {
			// Check if we've cycled back or if the active window moved monitor
			if activeWindow.Address == prevWindow || activeWindow.Monitor != monitorID {
				break // Reached the end or moved off the target monitor
			}

			client, err := ClientFromAddress(activeWindow.Address)
			println("Client from Address: ", client.Title, "on monitor", monitorID)
			if err != nil {
				println("Error getting client from Address: ", err)
				prevWindow = activeWindow.Address
				c.Dispatch("hy3:movefocus r, visible")
				// c.Dispatch("hy3:movefocus u, visible")
				activeWindow, err = c.ActiveWindow()
				if err != nil {
					println("Error getting next active window:", err)
					break // Break if we can't get the next window
				}
				continue // Continue the loop with the new active window
			}

			if !startProcessing {
				println("Skipping: ", client.Title, "on monitor", monitorID)
				matches, err := matchesApp(client, *args.After)
				if err != nil {
				}
				if matches {
					startProcessing = true
				}
			} else if len(args.Apps) == 0 || matchesAnyApp(client, args.Apps) {
				println("Dispatching: ", args.Command, "on monitor", monitorID, "for window", client.Title)
				// Note: The command here is applied to the *currently focused* window,
				// which we are iterating through on the target monitor.
				time.Sleep(sleepTime)
				c.Dispatch(args.Command)
			}

			prevWindow = activeWindow.Address

			c.Dispatch("hy3:movefocus r, visible")
			// c.Dispatch("hy3:movefocus u, visible")
			activeWindow, err = c.ActiveWindow()
			if err != nil {
				println("Error getting next active window:", err)
				break // Break loop if error getting next window
			}
		}
	}
}

type OrderedWindowsOptions struct {
	AppOrder []AppOptions
	Command  string
	Monitors []int
}

func processWindowsInOrder(args OrderedWindowsOptions) {
	for _, monitorID := range args.Monitors {
		windowsOnMonitor := clientsOnMonitor(monitorID)
		var orderedClients []hyprland.Client
		// Order clients based on AppOrder if provided
		tempWindows := make([]hyprland.Client, len(windowsOnMonitor))
		copy(tempWindows, windowsOnMonitor) // Work on a copy

		for _, app := range args.AppOrder {
			found := false
			for i, client := range tempWindows {
				matches, err := matchesApp(client, app)
				if err != nil {
					continue
				}
				if matches {
					orderedClients = append(orderedClients, client)
					// Remove client from tempWindows
					tempWindows = slices.Delete(tempWindows, i, i+1)
					found = true
					break
				}
			}
			if !found {
				// fmt.Printf("Warning: App '%s' from AppOrder not found on monitor %d\n", app, monitorID)
			}
		}
		for _, client := range orderedClients {
			cmd := fmt.Sprintf("%s address:%s", args.Command, client.Address)
			println("Dispatching: ", fmt.Sprintf("%s title:%s", args.Command, client.Title))
			time.Sleep(sleepTime)
			c.Dispatch(cmd)
		}
	}

}

// Address returns the address of the app if it is running
func Address(app AppOptions) (string, error) {
	clients, err := c.Clients()
	if err != nil {
		return "", err
	}
	for _, client := range clients {
		matches, err := matchesApp(client, app)
		if err != nil {
			continue
		}
		if matches {
			return client.Address, nil
		}
	}
	return "", fmt.Errorf("could not find address for app %s", app)
}

// matchesApp checks if a client matches the given app criteria
func matchesApp(client hyprland.Client, app AppOptions) (bool, error) {
	// Check by title if specified
	if app.title != "" {
		return strings.Contains(client.Title, app.title), nil
	}
	// Check by class if specified
	if app.class != "" {
		return client.Class == app.class, nil
	}

	// Otherwise check by app name
	clientAppName, err := AppNameFromPid(client.Pid)
	if err != nil {
		return false, err
	}
	return clientAppName == getAppName(app.app), nil
}

// matchesApp checks if a client matches the given app criteria
func matchesAnyApp(client hyprland.Client, app []AppOptions) bool {
	for _, a := range app {
		matches, err := matchesApp(client, a)
		if err != nil {
			continue
		}
		if matches {
			return true
		}
	}
	return false
}

// Gets the clients for a monitor
func clientsOnMonitor(monitor int) []hyprland.Client {
	var windowsOnMonitor []hyprland.Client

	clients, err := c.Clients()
	if err != nil {
		println("Error getting clients: ", err)
	} else {
		for _, client := range clients {
			if client.Monitor == monitor {
				windowsOnMonitor = append(windowsOnMonitor, client)
			}
		}
	}

	return windowsOnMonitor
}

func makeGroup(monitor int, first AppOptions, rest ...AppOptions) {
	firstAd := must(Address(first))
	println("Focusing and making tab group for ", first.app+" on monitor", monitor)
	c.Dispatch("focuswindow address:" + firstAd)
	c.Dispatch("hy3:makegroup tab, toggle")

	// Moves all the windows after thunar into the tab group
	processWindowsInSucession(WindowsInSuccessionOptions{
		After:    &first,
		Command:  "hy3:movewindow l",
		Monitors: []int{monitor},
		Apps:     rest,
	})
}
