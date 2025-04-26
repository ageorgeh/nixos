#!/usr/bin/env node
import { execSync } from "child_process";
import path from "path";

// Parse command line arguments
export function parseArgs(args: string[]): {
  useAddress: boolean;
  titleOrder: string;
  afterTitle: string;
  command: string;
  targetMonitor: number;
} {
  let useAddress = false;
  let titleOrder = "";
  let afterTitle = "";
  let command = "";
  let targetMonitor = -1;
  let i = 0;

  // Show help if requested
  if (args.includes("--help") || args.includes("-h")) {
    const scriptName = "allWindows";
    console.log(
      `Usage: ${scriptName} [--address] [--title-order "title1 title2 ..."] [--after title] <command> <monitor_number>`
    );
    console.log(
      "  - --address: Use window addresses explicitly instead of focusing (optional)"
    );
    console.log(
      "  - --title-order: Order windows by initial titles, space-separated list (requires --address)"
    );
    console.log(
      "  - --after: Start executing commands after finding first window of specified title"
    );
    console.log(
      "  - command: Hyprland command to run on each window (required)"
    );
    console.log("  - monitor_number: Which monitor to operate on (required)");
    console.log("");
    console.log("Examples:");
    console.log(
      `  ${scriptName} 'hy3:changegroup untab' 1     # Ungroups windows on monitor 1`
    );
    console.log(
      `  ${scriptName} --address 'togglefloating' 1  # Toggles floating on all windows on monitor 1`
    );
    console.log(
      `  ${scriptName} --address --title-order "Firefox Developer Edition Mozilla Firefox Thunar" 'togglefloating' 1`
    );
    console.log(
      `  ${scriptName} --after Thunar 'movetoworkspace special' 1  # Move windows after Thunar to special workspace`
    );
    process.exit(0);
  }

  // Parse flags and options
  while (i < args.length) {
    if (args[i] === "--address") {
      useAddress = true;
      i++;
    } else if (args[i] === "--title-order") {
      if (i + 1 >= args.length || args[i + 1].startsWith("--")) {
        console.error(
          "Error: --title-order requires a space-separated list of titles"
        );
        process.exit(1);
      }
      titleOrder = args[i + 1];
      i += 2;
    } else if (args[i] === "--after") {
      if (i + 1 >= args.length || args[i + 1].startsWith("--")) {
        console.error("Error: --after requires a title name");
        process.exit(1);
      }
      afterTitle = args[i + 1];
      i += 2;
    } else {
      // Remaining arguments are command and monitor
      break;
    }
  }

  // Get command and monitor
  if (i < args.length) {
    command = args[i];
    i++;
  }

  if (i < args.length) {
    targetMonitor = parseInt(args[i], 10);
  }

  // Validate required arguments
  if (!command || isNaN(targetMonitor)) {
    console.error("Error: Both command and monitor arguments are required");
    console.error(
      `Run '${path.basename(process.argv[1])} --help' for usage information`
    );
    process.exit(1);
  }

  // Validate that the monitor number is a positive integer
  if (targetMonitor < 0) {
    console.error("Error: Monitor number must be a positive integer");
    process.exit(1);
  }

  if (titleOrder && !useAddress) {
    console.error("Error: --title-order requires --address flag");
    process.exit(1);
  }

  return { useAddress, titleOrder, afterTitle, command, targetMonitor };
}

// Execute Hyprctl command and return JSON result
export function hyprctlJson(command: string): any {
  try {
    const result = execSync(`hyprctl ${command} -j`).toString();
    return JSON.parse(result);
  } catch (error) {
    console.error(`Error executing hyprctl ${command}: ${error}`);
    return null;
  }
}

// Execute a Hyprctl dispatch command
export function hyprctlDispatch(command: string): void {
  try {
    execSync(`hyprctl dispatch "${command}"`, { stdio: "ignore" });
  } catch (error) {
    console.error(`Error dispatching command: ${command}`);
  }
}

// Main function
export function processWindows(args: string[]): void {
  const { useAddress, titleOrder, afterTitle, command, targetMonitor } =
    parseArgs(args);

  if (useAddress) {
    console.log(`Collecting window addresses on monitor ${targetMonitor}`);

    // Get all windows on the target monitor
    const clients = hyprctlJson("clients");
    if (!clients) {
      console.error("Failed to get client list");
      process.exit(1);
    }

    // Filter for windows on the target monitor
    const windowsOnMonitor = clients.filter(
      (client: any) => client.monitor === targetMonitor
    );
    console.log(
      `Found ${windowsOnMonitor.length} windows on monitor ${targetMonitor}`
    );

    // Create a mapping by title
    const windowsByTitle: { [title: string]: string[] } = {};
    windowsOnMonitor.forEach((client: any) => {
      const title = client.initialTitle;
      if (!windowsByTitle[title]) {
        windowsByTitle[title] = [];
      }
      windowsByTitle[title].push(client.address);
    });

    // Create ordered list of window addresses
    let orderedAddresses: string[] = [];

    if (titleOrder) {
      console.log(`Ordering windows by specified title order: ${titleOrder}`);

      // Process windows in the specified title order
      const titlePatterns = titleOrder.split(" ");
      for (const pattern of titlePatterns) {
        for (const title in windowsByTitle) {
          if (title.includes(pattern)) {
            windowsByTitle[title].forEach((addr) => {
              orderedAddresses.push(addr);
              console.log(`Matched title pattern '${pattern}' with '${title}'`);
            });
            delete windowsByTitle[title];
          }
        }
      }

      // Add any remaining windows
      for (const title in windowsByTitle) {
        windowsByTitle[title].forEach((addr) => {
          orderedAddresses.push(addr);
        });
      }
    } else {
      // If no title order specified, use original order
      orderedAddresses = windowsOnMonitor.map((client: any) => client.address);
    }

    // Handle --after flag
    let startProcessing = afterTitle ? false : true;
    let afterTitleFound = false;

    for (const address of orderedAddresses) {
      // Find the title for this address to show in output
      const client = clients.find((c: any) => c.address === address);
      if (!client) continue;

      // Check if we've found the after_title
      if (
        afterTitle &&
        client.initialTitle.includes(afterTitle) &&
        !startProcessing
      ) {
        console.log(
          `Found window with title matching '${afterTitle}', will start processing from next window`
        );
        startProcessing = true;
        afterTitleFound = true;
        continue;
      }

      // Skip if we haven't started processing yet
      if (!startProcessing) {
        console.log(
          `Skipping ${address} (Title: ${client.initialTitle}) - waiting for '${afterTitle}'`
        );
        continue;
      }

      console.log(
        `Running '${command} address:${address}' (Title: ${client.initialTitle})`
      );
      hyprctlDispatch(`${command} address:${address}`);
    }

    if (afterTitle && !afterTitleFound) {
      console.log(
        `Warning: No window with title matching '${afterTitle}' found. No commands were executed.`
      );
    }
  } else {
    // Focus-based approach
    console.log(
      `Focusing on monitor ${targetMonitor}, running command: '${command}'`
    );
    hyprctlDispatch(`focusmonitor ${targetMonitor}`);

    // If --after is specified, find the window with that title
    let startProcessing = !afterTitle;
    let initialWindow = "";

    if (afterTitle) {
      console.log(
        `Will start executing after first window with title matching: ${afterTitle}`
      );

      // Get initial active window
      const activeWindow = hyprctlJson("activewindow");
      if (!activeWindow) {
        console.error("Failed to get active window");
        process.exit(1);
      }

      initialWindow = activeWindow.address;
      let currentWindow = initialWindow;
      let previousWindow = "";

      // Loop through windows to find the specified title
      let iteration = 0;
      const maxIterations = 50;
      let foundAfterTitle = false;

      while (iteration < maxIterations) {
        iteration++;

        // Check current window title
        const activeWindow = hyprctlJson("activewindow");
        if (!activeWindow) break;

        if (activeWindow.initialTitle.includes(afterTitle)) {
          console.log(
            `Found window with title matching '${afterTitle}', will start processing from next window`
          );
          foundAfterTitle = true;
          break;
        }

        // Move focus right
        hyprctlDispatch("hy3:movefocus r, visible, nowrap");

        // Get the new active window
        previousWindow = currentWindow;
        const newActiveWindow = hyprctlJson("activewindow");
        if (!newActiveWindow) break;
        currentWindow = newActiveWindow.address;

        // If we returned to the initial window or focus didn't change, we didn't find the title
        if (
          (currentWindow === initialWindow && iteration > 1) ||
          currentWindow === previousWindow
        ) {
          console.log(
            `Warning: No window with title matching '${afterTitle}' found. No commands will be executed.`
          );
          process.exit(0);
        }
      }

      if (!foundAfterTitle) {
        process.exit(0);
      }

      // Move to the next window (past the target title)
      hyprctlDispatch("hy3:movefocus r, visible, nowrap");

      // Reset for the actual command execution
      const newActiveWindow = hyprctlJson("activewindow");
      if (newActiveWindow) {
        initialWindow = newActiveWindow.address;
      }
    }

    // Execute commands on all windows
    let currentWindow = initialWindow;
    let previousWindow = "";
    const maxIterations = 50;
    let iteration = 0;

    while (iteration < maxIterations) {
      iteration++;

      // Run the custom command on current window
      const activeWindow = hyprctlJson("activewindow");
      if (!activeWindow) break;

      console.log(
        `Running '${command}' on window (Title: ${activeWindow.initialTitle})`
      );
      hyprctlDispatch(command);

      // Move focus right
      hyprctlDispatch("hy3:movefocus r, visible, nowrap");

      // Get the new active window
      previousWindow = currentWindow;
      const newActiveWindow = hyprctlJson("activewindow");
      if (!newActiveWindow) break;
      currentWindow = newActiveWindow.address;

      // If we returned to the initial window or focus didn't change, we're done
      if (
        (currentWindow === initialWindow && iteration > 1) ||
        currentWindow === previousWindow
      ) {
        console.log(
          `Completed running '${command}' on windows on monitor ${targetMonitor} after ${iteration} iterations`
        );
        break;
      }
    }
  }
}
