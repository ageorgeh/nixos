// Basic example on how to handle events in hyprland-go.
package main

import (
	"flag"
	"io"

	"github.com/thiagokokada/hyprland-go"
	"github.com/thiagokokada/hyprland-go/event"
)

var (
	c *hyprland.RequestClient
	// default error/usage output
	out io.Writer = flag.CommandLine.Output()
)

var (
	e *event.EventClient
	// default error/usage output
	eventsOut io.Writer = flag.CommandLine.Output()
)

type ev struct {
	event.DefaultEventHandler
	onOpen func(w event.OpenWindow)
}

func (e *ev) OpenWindow(w event.OpenWindow) {
	if e.onOpen != nil {
		e.onOpen(w)
	}
}

func main() {
	c = hyprland.MustClient()
	e = event.MustClient()
	apps := map[int][]string{
		0: {"code --ozone-platform=x11"},
		1: {"firefox-devedition",
			"firefox",
			"thunar",
			"keepassxc",
			"tidal-hifi"},
	}

	// Call the launchApps function
	launchApps(apps)
}
