#!/usr/bin/env node
import path from "path";
import { execSync } from "child_process";
import { fileURLToPath } from "url";
import { launchApps } from "./launch.ts";
import { processWindows } from "./allWindows.ts";
import { HyprlandIPC } from "./hyprland-ipc.ts";
import { HyprlandCmd } from "./hyprland-cmd.ts";

// Get the current directory where the script is located
const __filename = fileURLToPath(import.meta.url);
const SCRIPT_DIR = path.dirname(__filename);

// Helper function to run Hyprland commands
function hyprctl(command: string): void {
  console.log(`Running: hyprctl ${command}`);
  execSync(`hyprctl ${command}`, { stdio: "inherit" });
}

async function setupLayout(): Promise<void> {
  const ipc = new HyprlandIPC();

  // Launch all applications with the launcher
  console.log("Launching applications...");
  await launchApps({
    0: ["code --ozone-platform=x11"],
    1: [
      "--monitor1",
      "firefox-devedition",
      "firefox",
      "thunar",
      "keepassxc",
      "tidal-hifi",
    ],
  });

  // Ungroup all windows on monitor 1
  console.log("Ungrouping windows on monitor 1...");
  processWindows(["hy3:changegroup untab", "1"]);

  // Float them all
  console.log("Floating all windows on monitor 1...");
  processWindows(["--address", "togglefloating", "1"]);

  // Unfloat them all in correct order
  console.log("Unfloating windows in specific order...");
  processWindows([
    "--address",
    "--title-order",
    "Firefox Developer Edition Mozilla Firefox Thunar KeePassXC TIDAL",
    "togglefloating",
    "1",
  ]);

  // Make the ending group
  console.log("Creating tab group starting with Thunar...");
  hyprctl(`dispatch focuswindow "initialtitle:^Thunar$"`);
  hyprctl(`dispatch hy3:makegroup tab, toggle`);

  // Move things into the group
  console.log("Moving windows into the tab group...");
  processWindows(["--after", "Thunar", "hy3:movewindow l", "1"]);

  // Get the sizing correct
  console.log("Resizing windows...");
  hyprctl(`dispatch focusmonitor 0`); // This is required for some reason
  hyprctl(
    `dispatch resizewindowpixel exact 80% 100%, "initialtitle:^Firefox Developer Edition$"`
  );
  hyprctl(
    `dispatch resizewindowpixel exact 60% 100%, "initialtitle:^Mozilla Firefox$"`
  );

  // Focus back on code
  console.log("Focusing back on code (monitor 0)...");
  hyprctl(`dispatch focusmonitor 0`);

  console.log("Layout setup complete!");
}

// Execute the main function when this script is run directly
// setupLayout().catch((error) => {
//   console.error("Error during layout setup:", error);
//   process.exit(1);
// });
