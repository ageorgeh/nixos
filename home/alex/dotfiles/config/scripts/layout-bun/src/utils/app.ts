import { LayoutConfig, ManagedApp } from "../config";
import { HyprlandClient } from "../hyprland/client";
import { HyprClient, WindowMatcher } from "../hyprland/types";
import { setTimeout as sleep } from "node:timers/promises";
import { logStep, patternMatches } from "./utils";
import { readFile } from "node:fs/promises";
import { LayoutError } from "./errors";
import { LAUNCH_TIMEOUT_MS, LAUNCH_WAIT_INTERVAL_MS } from "./constants";

interface MatcherContext {
  commandNameByPid: Map<number, Promise<string | null>>;
}

export async function launchMissingApps(
  hypr: HyprlandClient,
  config: LayoutConfig,
): Promise<Map<string, HyprClient>> {
  const initialClients = await hypr.clients({ all: true });
  const alreadyRunning = await resolveApps(config.apps, initialClients);

  for (const running of alreadyRunning.values()) {
    logStep(`Already running: ${running.title}`);
  }

  const missingApps = config.apps.filter((app) => !alreadyRunning.has(app.id));

  if (missingApps.length === 0) {
    logStep("All managed apps are already running.");
    return alreadyRunning;
  }

  logStep(`Launching ${missingApps.length} missing apps concurrently.`);
  for (const missing of missingApps.values()) {
    logStep(`Running: ${missing.command}`);
  }

  await Promise.all(
    missingApps.map(async (app) => {
      await hypr.exec(app.command);
    }),
  );

  return await waitForApps(hypr, config.apps, LAUNCH_TIMEOUT_MS);
}

export async function resolveApps(
  apps: readonly ManagedApp[],
  clients: readonly HyprClient[],
): Promise<Map<string, HyprClient>> {
  const context: MatcherContext = {
    commandNameByPid: new Map<number, Promise<string | null>>(),
  };

  const result = new Map<string, HyprClient>();

  for (const app of apps) {
    const matches: HyprClient[] = [];
    for (const client of clients) {
      if (await matchesApp(client, app, context)) {
        matches.push(client);
      }
    }

    if (matches.length > 1) {
      throw new LayoutError(
        `App "${app.id}" matched ${matches.length} windows. Tighten the matcher.`,
      );
    }

    if (matches.length === 1) {
      result.set(app.id, matches[0]!);
    }
  }

  return result;
}

export async function waitForApps(
  hypr: HyprlandClient,
  apps: readonly ManagedApp[],
  timeoutMs: number,
): Promise<Map<string, HyprClient>> {
  const deadline = Date.now() + timeoutMs;

  while (Date.now() < deadline) {
    const clients = await hypr.clients({ all: true });
    const resolved = await resolveApps(apps, clients);
    if (resolved.size === apps.length) {
      return resolved;
    }

    await sleep(LAUNCH_WAIT_INTERVAL_MS);
  }

  throw new LayoutError(
    `Timed out waiting for apps: ${apps.map((app) => app.id).join(", ")}`,
  );
}

async function matchesApp(
  client: HyprClient,
  app: ManagedApp,
  context: MatcherContext,
): Promise<boolean> {
  if (await matchesMatcher(client, app.match, context)) {
    return true;
  }

  if (
    app.launchMatch &&
    (await matchesMatcher(client, app.launchMatch, context))
  ) {
    return true;
  }

  return false;
}

async function matchesMatcher(
  client: HyprClient,
  matcher: WindowMatcher,
  context: MatcherContext,
): Promise<boolean> {
  if (matcher.title && !patternMatches(matcher.title, client.title)) {
    return false;
  }
  if (
    matcher.initialTitle &&
    !patternMatches(matcher.initialTitle, client.initialTitle)
  ) {
    return false;
  }
  if (matcher.class && !patternMatches(matcher.class, client.class)) {
    return false;
  }
  if (
    matcher.initialClass &&
    !patternMatches(matcher.initialClass, client.initialClass)
  ) {
    return false;
  }
  if (matcher.xwayland !== undefined && matcher.xwayland !== client.xwayland) {
    return false;
  }
  if (matcher.commandName) {
    const commandName = await readCommandNameFromPid(context, client.pid);
    if (!commandName || !patternMatches(matcher.commandName, commandName)) {
      return false;
    }
  }

  return true;
}

async function readCommandNameFromPid(
  context: MatcherContext,
  pid: number,
): Promise<string | null> {
  let pending = context.commandNameByPid.get(pid);
  if (!pending) {
    pending = readFile(`/proc/${pid}/cmdline`, "utf8")
      .then((value) => normalizeCommandName(value))
      .catch(() => null);
    context.commandNameByPid.set(pid, pending);
  }

  return await pending;
}

function normalizeCommandName(command: string): string {
  let normalized = command.replaceAll("\x00", " ").trim();
  const firstSpace = normalized.indexOf(" ");
  if (firstSpace !== -1) {
    normalized = normalized.slice(0, firstSpace);
  }

  const pathSegments = normalized.split("/");
  normalized = pathSegments[pathSegments.length - 1] ?? normalized;
  normalized = normalized.replace(/^\./, "");
  normalized = normalized.replace(/-wrapped$/, "");
  return normalized.trim();
}
