// GOOS=linux GOARCH=amd64 go build -o layout .

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

func must[T any](input T, err error) T {
	if err != nil {
		panic(err)
	}
	return input
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
	launchApps(apps)

	processWindows(WindowsOptions{
		Command: "hy3:changegroup untab",
		Monitor: 1,
	})

	processWindows(WindowsOptions{
		UseAddress: true,
		Command:    "togglefloating",
		Monitor:    1,
	})

	processWindows(WindowsOptions{
		UseAddress: true,
		Command:    "togglefloating",
		Monitor:    1,
		AppOrder:   []string{"firefox-devedition", "firefox", "thunar", "keepassxc", "tidal-hifi"},
	})

	// Focus thunar and make it a tab group
	thunar := must(AddressFromAppName("thunar"))
	println("Focusing and making tab group for thunar: ", thunar)
	c.Dispatch("focuswindow address:" + thunar)
	c.Dispatch("hy3:makegroup tab, toggle")

	// Moves all the windows after thunar into the tab group
	processWindows(WindowsOptions{
		After:   "thunar",
		Command: "hy3:movewindow l",
		Monitor: 1,
	})

	c.Dispatch("focusmonitor 0")

	firefoxDev := must(AddressFromAppName("firefox-devedition"))
	firefox := must(AddressFromAppName("firefox"))
	c.Dispatch("resizewindowpixel exact 80% 100%, address:" + firefoxDev)
	c.Dispatch("resizewindowpixel exact 60% 100%, address:" + firefox)

}
