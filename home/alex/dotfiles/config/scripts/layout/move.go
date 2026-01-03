package main

import (
	"fmt"
	"strconv"
	"time"
)

// Moves open windows to their desired monitor
func moveWindows(apps map[int][]AppOptions) {
	type launchTask struct {
		window int
		app    AppOptions
	}

	tasks := make([]launchTask, 0)
	for window, list := range apps {
		for _, app := range list {
			tasks = append(tasks, launchTask{window: window, app: app})
		}
	}

	for _, task := range tasks {
		fmt.Println("moving", task.app, "to", task.window)
		if task.app.title != "" {
			c.Dispatch("focuswindow title:" + task.app.title)
		} else if task.app.class != "" {
			c.Dispatch("focuswindow class:" + task.app.class)
		} else if task.app.app != "" {
			pid, err := getPid(task.app.app)
			if err != nil {
				fmt.Println("Failed to get pid for", task.app.app, err)
			} else {
				c.Dispatch("focuswindow pid:" + strconv.Itoa(pid))
			}
		}

		fmt.Println("focused", task.app)
		time.Sleep(sleepTime)
		// time.Sleep(3 * time.Second)

		c.Dispatch("movewindow mon:" + strconv.Itoa(task.window))
		time.Sleep(sleepTime)
	}
}
