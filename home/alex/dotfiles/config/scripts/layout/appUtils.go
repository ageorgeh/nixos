package main

import (
	"fmt"
	"regexp"

	"github.com/thiagokokada/hyprland-go"
)

// IsRunning checks if the app is already running
//
// Checks by title first, then app name
func IsRunning(i AppOptions) bool {
	add, err := Address(i)
	if err != nil {
		return false
	} else if add != "" {
		return true
	}
	return false
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
		matched, err := regexp.MatchString(app.title, client.Title)
		if err != nil {
			// invalid regex
		}
		if matched {
			return true, nil
		}
	} else if app.class != "" {
		matched, err := regexp.MatchString(app.class, client.Class)
		if err != nil {
			// invalid regex
		}
		if matched {
			return true, nil
		}
	} else {
		// Otherwise check by app name
		clientAppName, err := AppNameFromPid(client.Pid)
		if err != nil {
			return false, err
		}
		return clientAppName == getAppName(app.app), nil
	}
	return false, nil

}
