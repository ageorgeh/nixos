package main

import (
	"fmt"

	"github.com/thiagokokada/hyprland-go"
)

type WindowsOptions struct {
	UseAddress bool
	AppOrder   []string
	After      string
	Command    string
	Monitors   []int // Changed from Monitor int
}

// processWindows now handles multiple monitors specified in args.Monitors
func processWindows(args WindowsOptions) {
	if args.Command == "" {
		panic("Command is required")
	}
	if len(args.Monitors) == 0 {
		// If no monitors specified, maybe default to all or current? Or panic?
		// For now, let's assume at least one monitor must be specified or handle it upstream.
		println("Warning: No monitors specified for processWindows")
		return
	}

	clients, err := c.Clients()
	if err != nil {
		println("Error getting clients: ", err)
		return
	}

	for _, monitorID := range args.Monitors {
		if args.UseAddress {
			var windowsOnMonitor []hyprland.Client
			for _, client := range clients {
				if client.Monitor == monitorID {
					windowsOnMonitor = append(windowsOnMonitor, client)
				}
			}

			var orderedClients []hyprland.Client
			// Order clients based on AppOrder if provided
			if len(args.AppOrder) > 0 {
				tempWindows := make([]hyprland.Client, len(windowsOnMonitor))
				copy(tempWindows, windowsOnMonitor) // Work on a copy

				for _, app := range args.AppOrder {
					found := false
					for i, client := range tempWindows {
						clientAppName, err := AppNameFromPid(client.Pid)
						if err != nil {
							continue
						}
						if clientAppName == getAppName(app) { // Use getAppName for consistency
							orderedClients = append(orderedClients, client)
							// Remove client from tempWindows
							tempWindows = append(tempWindows[:i], tempWindows[i+1:]...)
							found = true
							break
						}
					}
					if !found {
						// Optionally print a warning if an app in AppOrder wasn't found on this monitor
						// fmt.Printf("Warning: App '%s' from AppOrder not found on monitor %d\n", app, monitorID)
					}
				}
				// Add any remaining windows (not in AppOrder) to the end
				orderedClients = append(orderedClients, tempWindows...)
			} else {
				// If no AppOrder, use the original order from Hyprland
				orderedClients = windowsOnMonitor
			}

			var startProcessing bool = args.After == ""
			for _, client := range orderedClients {
				// Ensure the client is still on the correct monitor (it shouldn't change, but safety check)
				if client.Monitor != monitorID {
					continue
				}
				clientAppName, err := AppNameFromPid(client.Pid)
				if err != nil {
					continue
				}
				if !startProcessing {
					if clientAppName == getAppName(args.After) { // Use getAppName for consistency
						// Can start processing from the next client
						startProcessing = true
					}
					// Continue even if found, processing starts *after* this one
					continue
				}
				// else: startProcessing is true
				cmd := fmt.Sprintf("%s address:%s", args.Command, client.Address)
				println("Dispatching: ", cmd)
				c.Dispatch(cmd)

			}

		} else {
			// Non-UseAddress logic applied per monitor
			c.Dispatch("focusmonitor " + fmt.Sprint(monitorID))
			// Give focus a moment to settle? Might not be necessary.
			// time.Sleep(50 * time.Millisecond)

			activeWindow, err := c.ActiveWindow()
			if err != nil {
				println("Error getting active window for monitor", monitorID, ":", err)
				continue // Skip to the next monitor
			}
			// Check if the active window is actually on the focused monitor
			if activeWindow.Monitor != monitorID {
				println("Warning: Active window is not on the focused monitor", monitorID)
				// Maybe try to find *any* window on this monitor?
				// Or just skip this monitor if no window is active on it initially.
				continue
			}

			var startProcessing bool = args.After == ""
			var prevWindow string = ""
			maxIterations := 50 // Limit iterations per monitor

			for iteration := 0; iteration < maxIterations; iteration++ {
				// Check if we've cycled back or if the active window moved monitor
				if activeWindow.Address == prevWindow || activeWindow.Monitor != monitorID {
					break // Reached the end or moved off the target monitor
				}

				clientAppName, err := AppNameFromPid(activeWindow.Pid)
				if err != nil {
					println("Error getting app name: ", err)
					// Decide how to handle: skip this window or break? Let's skip.
					prevWindow = activeWindow.Address              // Mark as processed to avoid infinite loop on error
					c.Dispatch("hy3:movefocus r, visible, nowrap") // Try to move to the next
					activeWindow, err = c.ActiveWindow()
					if err != nil {
						println("Error getting next active window:", err)
						break // Break if we can't get the next window
					}
					continue // Continue the loop with the new active window
				}

				if !startProcessing {
					println("Skipping: ", clientAppName, "on monitor", monitorID)
					if clientAppName == getAppName(args.After) { // Use getAppName for consistency
						// Can start processing from the next client
						startProcessing = true
					}
				} else {
					println("Dispatching: ", args.Command, "on monitor", monitorID, "for window", clientAppName)
					// Note: The command here is applied to the *currently focused* window,
					// which we are iterating through on the target monitor.
					c.Dispatch(args.Command)
				}

				prevWindow = activeWindow.Address

				c.Dispatch("hy3:movefocus r, visible, nowrap")
				activeWindow, err = c.ActiveWindow()
				if err != nil {
					println("Error getting next active window:", err)
					break // Break loop if error getting next window
				}
			}
		}
	} // End loop over args.Monitors
}

func AddressFromAppName(app string) (string, error) {
	clients, err := c.Clients()
	if err != nil {
		return "", err
	}
	for _, client := range clients {
		clientAppName, err := AppNameFromPid(client.Pid)
		if err != nil {
			continue
		}
		if clientAppName == getAppName(app) {
			return client.Address, nil
		}
	}
	return "", fmt.Errorf("could not find address for app %s", app)
}
