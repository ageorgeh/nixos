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
	obsidian := AppOptions{
		app:   "obsidian",
		class: "obsidian",
	}
	noSqlWorkbench := AppOptions{
		app:          "nosql-workbench",
		initialTitle: "NoSQL Workbench",
		title:        "NoSQL Workbench",
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
		1: {firefoxDev, obsidian, noSqlWorkbench,
			firefox,
			thunar, keepassxc, tidalHifi},
	}

	launchApps(apps)

	// Untab all windows
	processWindowsInSucession(WindowsInSuccessionOptions{
		Command:  "hy3:changegroup untab",
		Monitors: []int{0, 1},
	})

	// // Float all windows
	processAllWindows(AllWindowsOptions{
		Command:  "setfloating",
		Monitors: []int{0, 1},
	})

	// // Unfloat windows in order
	processWindowsInOrder(OrderedWindowsOptions{
		Command:  "togglefloating",
		Monitors: []int{0, 1},
		AppOrder: []AppOptions{
			firefoxDev, obsidian, noSqlWorkbench,
			firefox,
			thunar, keepassxc, tidalHifi,
			nixosCode, cmsCode, kitty},
	})

	makeGroup(1, firefoxDev, obsidian, noSqlWorkbench)
	makeGroup(1, thunar, keepassxc, tidalHifi)
	makeGroup(0, nixosCode, cmsCode, kitty)

	c.Dispatch("focusmonitor 0")

	firefoxDevAd := must(Address(firefoxDev))
	firefoxAd := must(Address(firefox))
	c.Dispatch("resizewindowpixel exact 80% 100%, address:" + firefoxDevAd)
	c.Dispatch("resizewindowpixel exact 60% 100%, address:" + firefoxAd)

}
