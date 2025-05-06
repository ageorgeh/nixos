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

	nixosCode := AppOptions{
		app:          "code --use-angle=vulkan ~/nixos-config",
		title:        "nixos-config",
		initialTitle: "Visual Studio Code",
	}
	cmsCode := AppOptions{
		app:          "code --use-angle=vulkan ~/code/cmsWrapper/cms",
		title:        "cms",
		initialTitle: "Visual Studio Code",
	}

	kitty := AppOptions{
		app: "kitty",
	}

	firefoxDev := AppOptions{
		app: "firefox-devedition",
	}
	firefox := AppOptions{
		app: "firefox",
	}
	thunar := AppOptions{
		app: "thunar",
	}
	keepassxc := AppOptions{
		app: "keepassxc",
	}
	tidalHifi := AppOptions{
		app: "tidal-hifi",
	}

	apps := map[int][]AppOptions{
		0: {nixosCode, kitty, cmsCode},
		1: {firefoxDev, firefox, thunar, keepassxc, tidalHifi},
	}

	launchApps(apps)

	// Untab all windows
	processWindows(WindowsOptions{
		Command:  "hy3:changegroup untab",
		Monitors: []int{0, 1},
	})

	// Float all windows on monitor 1
	processWindows(WindowsOptions{
		UseAddress: true,
		Command:    "togglefloating",
		Monitors:   []int{0, 1},
	})

	// Unfloat windows on monitor 1 in order
	processWindows(WindowsOptions{
		UseAddress: true,
		Command:    "togglefloating",
		Monitors:   []int{0, 1},
		AppOrder:   []AppOptions{firefoxDev, firefox, thunar, keepassxc, tidalHifi, nixosCode, cmsCode, kitty}},
	)

	// TODO disable auto tile for this whole thing really and then enable when done
	// Focus thunar and make it a tab group
	thunarAd := must(Address(thunar))
	println("Focusing and making tab group for thunar: ", thunarAd)
	c.Dispatch("focuswindow address:" + thunarAd)
	c.Dispatch("hy3:makegroup tab, toggle")

	// Moves all the windows after thunar into the tab group
	processWindows(WindowsOptions{
		After:    &thunar,
		Command:  "hy3:movewindow l",
		Monitors: []int{1},
	})

	codeAd := must(Address(nixosCode))
	println("Focusing and making tab group for nixos code: ", codeAd)
	c.Dispatch("focuswindow address:" + codeAd)
	c.Dispatch("hy3:makegroup tab, toggle")

	// Moves all the windows after code into the tab group
	processWindows(WindowsOptions{
		After:    &nixosCode,
		Command:  "hy3:movewindow l",
		Monitors: []int{0},
	})

	c.Dispatch("focusmonitor 0")

	firefoxDevAd := must(Address(firefoxDev))
	firefoxAd := must(Address(firefox))
	c.Dispatch("resizewindowpixel exact 80% 100%, address:" + firefoxDevAd)
	c.Dispatch("resizewindowpixel exact 60% 100%, address:" + firefoxAd)

}
