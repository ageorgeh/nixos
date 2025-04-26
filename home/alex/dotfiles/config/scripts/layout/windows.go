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
	Monitor    int
}

func processWindows(args WindowsOptions) {
	if args.Command == "" {
		panic("Command is required")
	}
	if args.UseAddress {
		clients, err := c.Clients()
		if err != nil {
			return
		}
		var windowsOnMonitor []hyprland.Client
		for _, client := range clients {
			if client.Monitor == args.Monitor {
				windowsOnMonitor = append(windowsOnMonitor, client)
			}
		}

		var orderedClients []hyprland.Client
		for _, app := range args.AppOrder {
			for i, client := range windowsOnMonitor {
				clientAppName, err := AppNameFromPid(client.Pid)
				if err != nil {
					continue
				}
				if clientAppName == app {
					orderedClients = append(orderedClients, client)
					// Remove client from windowsOnMonitor
					windowsOnMonitor = append(windowsOnMonitor[:i], windowsOnMonitor[i+1:]...)
					break
				}
			}
		}
		// Add any remaining windows to the end of the list
		orderedClients = append(orderedClients, windowsOnMonitor...)

		var startProcessing bool = args.After == ""
		for _, client := range orderedClients {
			clientAppName, err := AppNameFromPid(client.Pid)
			if err != nil {
				continue
			}
			if !startProcessing {
				if clientAppName == args.After {
					// Can start processing from the next client
					startProcessing = true
					continue
				}
			} else {
				cmd := fmt.Sprintf("%s address:%s", args.Command, client.Address)
				println("Dispatching: ", cmd)
				c.Dispatch(cmd)
			}
		}

	} else {
		c.Dispatch("focusmonitor " + fmt.Sprint(args.Monitor))
		var startProcessing bool = args.After == ""
		var activeWindow, err = c.ActiveWindow()
		if err != nil {
			return
		}
		var prevWindow string = ""

		var iteration int = 0
		maxIterations := 50
		for iteration < maxIterations {
			if activeWindow.Address == prevWindow {
				// Reached the end of the monitor
				break
			}
			iteration++
			clientAppName, err := AppNameFromPid(activeWindow.Pid)
			if err != nil {
				continue
			}
			if !startProcessing {
				if clientAppName == args.After {
					// Can start processing from the next client
					startProcessing = true
					continue
				}
			} else {
				println("Dispatching: ", args.Command)
				c.Dispatch(args.Command)
				c.Dispatch("hy3:movefocus r, visible, nowrap")
			}

			prevWindow = activeWindow.Address
			activeWindow, err = c.ActiveWindow()
			if err != nil {
				return
			}
		}
	}
}
