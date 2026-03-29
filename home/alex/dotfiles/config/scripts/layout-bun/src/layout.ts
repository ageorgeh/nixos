import { readFile } from "node:fs/promises";
import { setTimeout as sleep } from "node:timers/promises";

import { layoutConfig, type LayoutConfig, type ManagedApp } from "./config";
import { HyprlandClient } from "./hyprland/client";
import type {
  HyprAddress,
  HyprClient,
  MatchPattern,
  MonitorSelector,
  WindowMatcher,
} from "./hyprland/types";
import { launchMissingApps, resolveApps, waitForApps } from "./utils/app";
import { LayoutError } from "./utils/errors";
import {
  STEP_DELAY_MS,
  LAUNCH_TIMEOUT_MS,
  STATE_WAIT_INTERVAL_MS,
  FOCUS_MAX_STEPS,
  ORDER_MAX_PASSES,
  GROUP_SETTLE_MS,
} from "./utils/constants";
import { logStep } from "./utils/utils";

function sortApps(apps: readonly ManagedApp[]): ManagedApp[] {
  return [...apps].sort((left, right) => {
    if (left.targetMonitor !== right.targetMonitor) {
      return left.targetMonitor - right.targetMonitor;
    }

    return left.order - right.order;
  });
}

function uniqueMonitorIds(apps: readonly ManagedApp[]): number[] {
  return [...new Set(apps.map((app) => app.targetMonitor))].sort(
    (left, right) => left - right,
  );
}

function selectorForAddress(address: HyprAddress): {
  type: "address";
  value: HyprAddress;
} {
  return { type: "address", value: address };
}

async function settle(ms = STEP_DELAY_MS): Promise<void> {
  await sleep(ms);
}

async function untabEverything(
  hypr: HyprlandClient,
  monitorIds: readonly number[],
): Promise<void> {
  const clients = await hypr.clients();

  for (const monitorId of monitorIds) {
    const onMonitor = clients.filter((client) => client.monitor === monitorId);
    for (const client of onMonitor) {
      await hypr.focusWindow(selectorForAddress(client.address));
      await settle();
      await hypr.dispatchRaw("hy3:changegroup", "untab");
      await settle();
    }
  }
}

async function unfloatEverything(
  hypr: HyprlandClient,
  monitorIds: readonly number[],
): Promise<void> {
  const clients = await hypr.clients();
  const commands = clients
    .filter((client) => monitorIds.includes(client.monitor))
    .map((client) => `dispatch settiled address:${client.address}`);

  if (commands.length > 0) {
    await hypr.batch(commands);
  }
}

async function waitForWindowOnMonitor(
  hypr: HyprlandClient,
  address: HyprAddress,
  monitorId: number,
  timeoutMs = 5_000,
): Promise<void> {
  const deadline = Date.now() + timeoutMs;

  while (Date.now() < deadline) {
    const clients = await hypr.clients({ all: true });
    const client = clients.find((item) => item.address === address);
    if (client && client.monitor === monitorId) {
      return;
    }

    await sleep(STATE_WAIT_INTERVAL_MS);
  }

  throw new LayoutError(
    `Timed out waiting for ${address} to reach monitor ${monitorId}.`,
  );
}

async function moveWindowsToAssignedMonitors(
  hypr: HyprlandClient,
  apps: readonly ManagedApp[],
  resolvedApps: ReadonlyMap<string, HyprClient>,
): Promise<void> {
  for (const app of sortApps(apps)) {
    const client = resolvedApps.get(app.id);
    if (!client) {
      throw new LayoutError(`Resolved app missing before move step: ${app.id}`);
    }

    if (client.monitor === app.targetMonitor) {
      continue;
    }

    logStep(`Moving ${app.id} to monitor ${app.targetMonitor}.`);
    await hypr.focusWindow(selectorForAddress(client.address));
    await settle();
    await hypr.moveActiveWindowToMonitor(app.targetMonitor, { silent: true });
    await settle();
    await waitForWindowOnMonitor(hypr, client.address, app.targetMonitor);
  }
}

async function focusFirstWindowOnMonitor(
  hypr: HyprlandClient,
  monitorId: number,
): Promise<HyprClient | null> {
  await hypr.focusMonitor(monitorId);
  await settle();

  let active = await hypr.activeWindow();
  if (!active || active.monitor !== monitorId) {
    const clients = await hypr.clients();
    const fallback = clients
      .filter((client) => client.monitor === monitorId)
      .sort(
        (left, right) => left.at[0] - right.at[0] || left.at[1] - right.at[1],
      )[0];

    if (!fallback) {
      return null;
    }

    await hypr.focusWindow(selectorForAddress(fallback.address));
    // await settle();
    active = await hypr.activeWindow();
  }

  if (!active || active.monitor !== monitorId) {
    return null;
  }

  let previousAddress: string | null = null;
  for (let step = 0; step < FOCUS_MAX_STEPS; step += 1) {
    if (!active || active.monitor !== monitorId) {
      break;
    }

    if (active.address === previousAddress) {
      break;
    }

    previousAddress = active.address;
    await hypr.dispatchRaw("hy3:movefocus", "l, visible");
    // await settle();
    const next = await hypr.activeWindow();
    if (!next) {
      break;
    }

    if (next.monitor !== monitorId) {
      await hypr.dispatchRaw("hy3:movefocus", "r, visible");
      // await settle();
      break;
    }

    active = next;
  }

  return await hypr.activeWindow();
}

async function readMonitorWindowOrder(
  hypr: HyprlandClient,
  monitorId: number,
): Promise<HyprClient[]> {
  const first = await focusFirstWindowOnMonitor(hypr, monitorId);
  if (!first || first.monitor !== monitorId) {
    return [];
  }

  const ordered: HyprClient[] = [];
  const seen = new Set<string>();
  let current: HyprClient | null = first;

  for (let step = 0; step < FOCUS_MAX_STEPS; step += 1) {
    if (
      !current ||
      current.monitor !== monitorId ||
      seen.has(current.address)
    ) {
      break;
    }

    ordered.push(current);
    seen.add(current.address);

    await hypr.dispatchRaw("hy3:movefocus", "r, visible");
    // await settle();
    current = await hypr.activeWindow();
  }

  return ordered;
}

async function sortWindowsOnMonitors(
  hypr: HyprlandClient,
  apps: readonly ManagedApp[],
  resolvedApps: ReadonlyMap<string, HyprClient>,
): Promise<void> {
  const appsByMonitor = new Map<number, ManagedApp[]>();
  for (const app of sortApps(apps)) {
    const list = appsByMonitor.get(app.targetMonitor) ?? [];
    list.push(app);
    appsByMonitor.set(app.targetMonitor, list);
  }

  const addressToAppId = new Map<HyprAddress, string>();
  for (const [appId, client] of resolvedApps.entries()) {
    addressToAppId.set(client.address, appId);
  }

  for (const [monitorId, monitorApps] of appsByMonitor.entries()) {
    const desiredOrder = monitorApps.map((app) => app.id);
    if (desiredOrder.length <= 1) {
      continue;
    }

    for (let pass = 0; pass < ORDER_MAX_PASSES; pass += 1) {
      const currentOrder = await readMonitorWindowOrder(hypr, monitorId);
      const actualOrder = currentOrder
        .map((client) => addressToAppId.get(client.address))
        .filter((appId): appId is string => appId !== undefined);

      if (desiredOrder.every((appId, index) => actualOrder[index] === appId)) {
        break;
      }

      const firstMismatch = desiredOrder.findIndex(
        (appId, index) => actualOrder[index] !== appId,
      );
      if (firstMismatch === -1) {
        break;
      }

      const desiredAppId = desiredOrder[firstMismatch];
      if (!desiredAppId) {
        throw new LayoutError(
          `Missing desired app id for monitor ${monitorId}.`,
        );
      }
      const targetClient = resolvedApps.get(desiredAppId);
      if (!targetClient) {
        throw new LayoutError(
          `Resolved app missing during ordering: ${desiredAppId}`,
        );
      }

      logStep(`Ordering ${desiredAppId} on monitor ${monitorId}.`);
      await hypr.focusWindow(selectorForAddress(targetClient.address));
      await settle();

      let placed = false;
      for (
        let moveCount = 0;
        moveCount < currentOrder.length + 4;
        moveCount += 1
      ) {
        const latestOrder = await readMonitorWindowOrder(hypr, monitorId);
        const latestPlannedOrder = latestOrder
          .map((client) => addressToAppId.get(client.address))
          .filter((appId): appId is string => appId !== undefined);

        if (latestPlannedOrder[firstMismatch] === desiredAppId) {
          placed = true;
          break;
        }

        await hypr.focusWindow(selectorForAddress(targetClient.address));
        // await settle();

        await hypr.dispatchRaw("hy3:movewindow", "l");
        // await settle(5);
      }

      if (!placed) {
        throw new LayoutError(
          `Failed to position ${desiredAppId} on monitor ${monitorId}.`,
        );
      }
    }

    const finalOrder = (await readMonitorWindowOrder(hypr, monitorId))
      .map((client) => addressToAppId.get(client.address))
      .filter((appId): appId is string => appId !== undefined);

    if (!desiredOrder.every((appId, index) => finalOrder[index] === appId)) {
      throw new LayoutError(
        `Could not fully sort monitor ${monitorId}. Desired: ${desiredOrder.join(", ")}. Actual: ${finalOrder.join(", ")}`,
      );
    }
  }
}

function groupRuns(apps: readonly ManagedApp[]): ManagedApp[][] {
  const runs: ManagedApp[][] = [];
  let current: ManagedApp[] = [];

  for (const app of sortApps(apps)) {
    if (!app.group) {
      if (current.length > 1) {
        runs.push(current);
      }
      current = [];
      continue;
    }

    const previous = current[current.length - 1];
    if (
      !previous ||
      (previous.group === app.group &&
        previous.targetMonitor === app.targetMonitor)
    ) {
      current.push(app);
      continue;
    }

    if (current.length > 1) {
      runs.push(current);
    }
    current = [app];
  }

  if (current.length > 1) {
    runs.push(current);
  }

  return runs;
}

async function createGroups(
  hypr: HyprlandClient,
  apps: readonly ManagedApp[],
  resolvedApps: ReadonlyMap<string, HyprClient>,
): Promise<void> {
  for (const run of groupRuns(apps)) {
    const leader = run[0]!;
    const members = run.slice(1);
    const leaderClient = resolvedApps.get(leader.id);
    if (!leaderClient) {
      throw new LayoutError(`Leader app missing for group ${leader.group}.`);
    }

    logStep(
      `Creating group ${leader.group} on monitor ${leader.targetMonitor}.`,
    );
    await hypr.focusWindow(selectorForAddress(leaderClient.address));
    await settle();
    await hypr.dispatchRaw("hy3:makegroup", "tab, toggle");
    // await settle();

    for (const member of members) {
      const memberClient = resolvedApps.get(member.id);
      if (!memberClient) {
        throw new LayoutError(`Group member missing for ${member.id}.`);
      }

      await hypr.focusWindow(selectorForAddress(memberClient.address));
      // await settle();
      await hypr.dispatchRaw("hy3:movewindow", "l");
      await settle();
    }
  }
}

async function applyResizes(
  hypr: HyprlandClient,
  apps: readonly ManagedApp[],
  resolvedApps: ReadonlyMap<string, HyprClient>,
): Promise<void> {
  const commands: string[] = [];

  for (const app of apps) {
    if (!app.resize) {
      continue;
    }

    const client = resolvedApps.get(app.id);
    if (!client) {
      throw new LayoutError(`Resize target missing: ${app.id}`);
    }

    commands.push(
      `dispatch resizewindowpixel exact ${app.resize.width} ${app.resize.height}, address:${client.address}`,
    );
  }

  if (commands.length > 0) {
    await hypr.batch(commands);
  }
}

function validateConfig(config: LayoutConfig): void {
  const appIds = new Set<string>();
  const positions = new Set<string>();

  for (const app of config.apps) {
    if (appIds.has(app.id)) {
      throw new LayoutError(`Duplicate app id: ${app.id}`);
    }
    appIds.add(app.id);

    const positionKey = `${app.targetMonitor}:${app.order}`;
    if (positions.has(positionKey)) {
      throw new LayoutError(`Duplicate monitor/order slot: ${positionKey}`);
    }
    positions.add(positionKey);
  }
}

export async function runManagedLayout(
  config: LayoutConfig = layoutConfig,
): Promise<void> {
  validateConfig(config);

  const hypr = new HyprlandClient();
  try {
    const monitorIds = uniqueMonitorIds(config.apps);

    logStep("Launching apps.");
    const resolvedApps = await launchMissingApps(hypr, config);

    logStep("Untabbing everything.");
    await untabEverything(hypr, monitorIds);

    logStep("Untiling floating windows.");
    await unfloatEverything(hypr, monitorIds);

    logStep("Moving windows to target monitors.");
    await moveWindowsToAssignedMonitors(hypr, config.apps, resolvedApps);

    logStep("Sorting windows.");
    await sortWindowsOnMonitors(hypr, config.apps, resolvedApps);

    logStep("Creating groups.");
    await createGroups(hypr, config.apps, resolvedApps);

    logStep("Applying resizes.");
    await applyResizes(hypr, config.apps, resolvedApps);

    const primaryMonitor = monitorIds[0];
    if (primaryMonitor !== undefined) {
      await hypr.focusMonitor(primaryMonitor as MonitorSelector);
    }

    logStep("Layout complete.");
  } finally {
    hypr.close();
  }
}
