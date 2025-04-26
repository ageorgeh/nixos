#!/usr/bin/env node
import { exec, execSync } from "child_process";
import { config } from "process";
import { promisify } from "util";

const execAsync = promisify(exec);

export interface AppConfig {
  monitor0: string[];
  monitor1: string[];
}

// Parse command line arguments
export function parseArgs(args: string[]): AppConfig {
  const config: AppConfig = {
    monitor0: [],
    monitor1: [],
  };

  let currentMonitor = 0;

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];

    if (arg === "--monitor") {
      if (i + 1 < args.length) {
        currentMonitor = parseInt(args[i + 1], 10);
        i++;
      }
    } else if (arg === "--monitor0") {
      currentMonitor = 0;
    } else if (arg === "--monitor1") {
      currentMonitor = 1;
    } else {
      // Add the application to the appropriate monitor array
      if (currentMonitor === 0) {
        config.monitor0.push(arg);
      } else {
        config.monitor1.push(arg);
      }
    }
  }

  return config;
}

// Get application title pattern for identification
export function getAppTitlePattern(app: string): string {
  if (app.includes("firefox-devedition") || app.includes("firefox-dev")) {
    return "Firefox Developer Edition";
  } else if (app === "firefox") {
    return "Mozilla Firefox";
  } else if (app.startsWith("code")) {
    return "Visual Studio Code";
  } else if (app === "thunar") {
    return "Thunar";
  } else if (app === "keepassxc") {
    return "KeePassXC";
  } else if (app === "tidal-hifi") {
    return "TIDAL";
  } else {
    // Return the first word as a fallback
    return app.split(" ")[0];
  }
}

// Check if an app is running using hyprctl
export function isRunning(app: string): boolean {
  try {
    const appTitlePattern = getAppTitlePattern(app);
    const result = execSync(
      `hyprctl clients -j | jq -e '.[] | select(.initialTitle | test("${appTitlePattern}"; "i"))'`
    );
    return result.toString().trim() !== "";
  } catch (error) {
    return false;
  }
}

// Wait for window to appear
export async function waitForWindow(
  appName: string,
  monitorNum: number
): Promise<boolean> {
  const appTitlePattern = getAppTitlePattern(appName);
  const maxWait = 15; // Maximum wait time in seconds

  console.log(
    `Waiting for window with title matching '${appTitlePattern}' to appear on monitor ${monitorNum}...`
  );

  for (let waitCount = 0; waitCount < maxWait; waitCount++) {
    try {
      // Check if the app is visible on the specified monitor
      const result = execSync(
        `hyprctl clients -j | jq -e '.[] | select(.initialTitle | test("${appTitlePattern}"; "i")) | select(.monitor == ${monitorNum})'`
      );
      if (result.toString().trim() !== "") {
        console.log(
          `Window with title matching '${appTitlePattern}' is now visible on monitor ${monitorNum}`
        );
        return true;
      }
    } catch (error) {
      // jq returns non-zero when no match is found
    }

    await new Promise((resolve) => setTimeout(resolve, 1000));
  }

  console.log(
    `Warning: Timed out waiting for window with title matching '${appTitlePattern}' on monitor ${monitorNum}`
  );
  return false;
}

// Main function
export async function launchApps(args: {
  [key: number]: string[];
}): Promise<void> {
  // Launch applications on monitor 0
  if (args[0].length > 0) {
    console.log("Launching applications on monitor 0...");
    execSync("hyprctl dispatch focusmonitor 0");

    for (const app of args[0]) {
      if (!isRunning(app)) {
        console.log(`Launching ${app} on monitor 0`);
        exec(app);
        await waitForWindow(app, 0);
      } else {
        console.log(
          `App with title matching '${getAppTitlePattern(
            app
          )}' is already running`
        );
      }
    }
  }

  // Launch applications on monitor 1
  if (args[1].length > 0) {
    console.log("Launching applications on monitor 1...");
    execSync("hyprctl dispatch focusmonitor 1");

    for (const app of args[1]) {
      if (!isRunning(app)) {
        console.log(`Launching ${app} on monitor 1`);
        exec(app);
        await waitForWindow(app, 1);
      } else {
        console.log(
          `App with title matching '${getAppTitlePattern(
            app
          )}' is already running`
        );
      }
    }
  }

  console.log("All applications launched and confirmed");
}
