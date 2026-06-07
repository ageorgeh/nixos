#!/usr/bin/env bun

import { spawn } from "node:child_process";

import { runManagedLayout } from "./src/layout";

const APP_NAME = "layout-bun";

function formatError(error: unknown): {
  logMessage: string;
  notificationMessage: string;
} {
  if (error instanceof Error) {
    return {
      logMessage: error.stack ?? error.message,
      notificationMessage: error.message || error.name,
    };
  }

  const message = String(error);
  return {
    logMessage: message,
    notificationMessage: message,
  };
}

async function sendNotification(
  title: string,
  message: string,
  urgency: "low" | "normal" | "critical" = "normal",
): Promise<void> {
  if (process.platform !== "linux") {
    return;
  }

  await new Promise<void>((resolve) => {
    const child = spawn(
      "notify-send",
      [`--app-name=${APP_NAME}`, `--urgency=${urgency}`, title, message],
      { stdio: "ignore" },
    );

    child.once("error", () => resolve());
    child.once("exit", () => resolve());
  });
}

async function main(): Promise<void> {
  try {
    await runManagedLayout();
    await sendNotification("Layout Complete", "> Layout complete.", "low");
  } catch (error: unknown) {
    const { logMessage, notificationMessage } = formatError(error);
    console.error(logMessage);
    await sendNotification("Layout Failed", notificationMessage, "critical");
    process.exitCode = 1;
  }
}

await main();
