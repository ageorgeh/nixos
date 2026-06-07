import { readFile } from "node:fs/promises";
import { setTimeout as sleep } from "node:timers/promises";

import { layoutConfig, type LayoutConfig, type ManagedApp } from "./config";
import { HyprlandClient } from "./hyprland/client";
import type {
  HyprAddress,
  HyprClient,
  HyprMonitor,
  MatchPattern,
  MonitorSelector,
  PixelOrPercent,
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
      await hypr.command("focus", {
        window: selectorForAddress(client.address),
      });
      await settle();
      await hypr.command("hy3", "change_group", "untab");
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
    .map((client) =>
      hypr.buildCommand("window", "float", {
        action: "disable",
        window: selectorForAddress(client.address),
      }),
    );

  if (commands.length > 0) {
    await hypr.batch(commands);
  }
}

async function waitForWindowOnMonitor(
  hypr: HyprlandClient,
  address: HyprAddress,
  monitorId: number,
  timeoutMs = 10_000,
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
    `Timed out (${timeoutMs}) waiting for ${address} to reach monitor ${monitorId}.`,
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
    await hypr.command("focus", { window: selectorForAddress(client.address) });
    await settle();
    await hypr.command("window", "move", {
      monitor: app.targetMonitor,
      follow: false,
    });
    await settle();
    await waitForWindowOnMonitor(hypr, client.address, app.targetMonitor);
  }
}

function compareClientsByPosition(left: HyprClient, right: HyprClient): number {
  return (
    left.at[0] - right.at[0] ||
    left.at[1] - right.at[1] ||
    left.size[0] - right.size[0] ||
    left.size[1] - right.size[1] ||
    left.address.localeCompare(right.address)
  );
}

async function focusFirstWindowOnMonitor(
  hypr: HyprlandClient,
  monitorId: number,
): Promise<HyprClient | null> {
  const first = (await hypr.clients())
    .filter(
      (client) =>
        client.monitor === monitorId &&
        client.mapped &&
        !client.hidden &&
        !client.floating,
    )
    .sort(compareClientsByPosition)[0];

  if (!first) {
    return null;
  }

  await hypr.command("focus", {
    window: selectorForAddress(first.address),
  });
  await settle();

  const active = await hypr.activeWindow();
  if (!active || active.address !== first.address) {
    throw new LayoutError(
      `Failed to focus first window ${first.address} on monitor ${monitorId}.`,
    );
  }

  return active;
}

async function readMonitorWindowOrder(
  hypr: HyprlandClient,
  monitorId: number,
): Promise<HyprClient[]> {
  const first = await focusFirstWindowOnMonitor(hypr, monitorId);

  console.log("First", first?.title);
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

    await hypr.command("focus", { direction: "r" });
    // await settle();
    current = await hypr.activeWindow();
  }

  return ordered;
}

function ordersMatch(
  desiredOrder: readonly string[],
  actualOrder: readonly string[],
): boolean {
  return desiredOrder.every((appId, index) => actualOrder[index] === appId);
}

function planMonitorWindowMoves(
  monitorId: number,
  currentOrder: readonly string[],
  desiredOrder: readonly string[],
): Array<{ appId: string; direction: "l" | "r"; steps: number }> {
  if (currentOrder.length !== desiredOrder.length) {
    console.error("Current vs desired", currentOrder, desiredOrder);
    throw new LayoutError(
      `Cannot sort monitor ${monitorId}: desired count ${desiredOrder.length} does not match actual count ${currentOrder.length}.`,
    );
  }

  const desiredSet = new Set(desiredOrder);
  const currentSet = new Set(currentOrder);
  const missing = desiredOrder.filter((appId) => !currentSet.has(appId));
  const extras = currentOrder.filter((appId) => !desiredSet.has(appId));
  if (missing.length > 0 || extras.length > 0) {
    throw new LayoutError(
      `Cannot sort monitor ${monitorId}: missing [${missing.join(", ")}], extra [${extras.join(", ")}].`,
    );
  }

  const workingOrder = [...currentOrder];
  const moves: Array<{ appId: string; direction: "l" | "r"; steps: number }> =
    [];

  for (
    let targetIndex = 0;
    targetIndex < desiredOrder.length;
    targetIndex += 1
  ) {
    const desiredAppId = desiredOrder[targetIndex];
    if (!desiredAppId) {
      throw new LayoutError(
        `Missing desired app id for monitor ${monitorId} at index ${targetIndex}.`,
      );
    }

    const currentIndex = workingOrder.indexOf(desiredAppId);
    if (currentIndex === -1) {
      throw new LayoutError(
        `Current order missing ${desiredAppId} on monitor ${monitorId}.`,
      );
    }

    if (currentIndex === targetIndex) {
      continue;
    }

    const direction = currentIndex > targetIndex ? "l" : "r";
    moves.push({
      appId: desiredAppId,
      direction,
      steps: Math.abs(currentIndex - targetIndex),
    });

    workingOrder.splice(currentIndex, 1);
    workingOrder.splice(targetIndex, 0, desiredAppId);
  }

  return moves;
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

      if (ordersMatch(desiredOrder, actualOrder)) {
        break;
      }

      for (const move of planMonitorWindowMoves(
        monitorId,
        actualOrder,
        desiredOrder,
      )) {
        const targetClient = resolvedApps.get(move.appId);
        if (!targetClient) {
          throw new LayoutError(
            `Resolved app missing during ordering: ${move.appId}`,
          );
        }

        logStep(
          `Ordering ${move.appId} on monitor ${monitorId} (${move.steps} ${move.direction}).`,
        );
        await hypr.command("focus", {
          window: selectorForAddress(targetClient.address),
        });
        await settle();

        for (let step = 0; step < move.steps; step += 1) {
          await hypr.command("hy3", "move_window", move.direction);
          await settle();
        }
      }
    }

    const finalOrder = (await readMonitorWindowOrder(hypr, monitorId))
      .map((client) => addressToAppId.get(client.address))
      .filter((appId): appId is string => appId !== undefined);

    if (!ordersMatch(desiredOrder, finalOrder)) {
      console.error(
        `Could not fully sort monitor ${monitorId}. Desired: ${desiredOrder.join(", ")}. Actual: ${finalOrder.join(", ")}`,
      );
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
    await hypr.command("focus", {
      window: selectorForAddress(leaderClient.address),
    });
    await settle();
    await hypr.command("hy3", "make_group", "tab", { toggle: true });
    // await settle();

    for (const member of members) {
      const memberClient = resolvedApps.get(member.id);
      if (!memberClient) {
        throw new LayoutError(`Group member missing for ${member.id}.`);
      }

      await hypr.command("focus", {
        window: selectorForAddress(memberClient.address),
      });
      // await settle();
      await hypr.command("hy3", "move_window", "l");
      await settle();
    }
  }
}

function monitorInnerWidth(monitor: HyprMonitor): number {
  return monitor.width - monitor.reserved[2] - monitor.reserved[3];
}

function monitorInnerHeight(monitor: HyprMonitor): number {
  return monitor.height - monitor.reserved[0] - monitor.reserved[1];
}

function resolvePixelOrPercent(value: PixelOrPercent, total: number): number {
  if (typeof value === "number") {
    return Math.round(value);
  }

  const ratio = Number.parseFloat(value.slice(0, -1));
  if (Number.isNaN(ratio)) {
    throw new LayoutError(`Invalid percentage resize value: ${value}`);
  }

  return Math.round((total * ratio) / 100);
}

async function applyResizes(
  hypr: HyprlandClient,
  apps: readonly ManagedApp[],
  resolvedApps: ReadonlyMap<string, HyprClient>,
): Promise<void> {
  const monitors = await hypr.monitors({ all: true });
  const monitorsById = new Map(
    monitors.map((monitor) => [monitor.id, monitor]),
  );
  const commands: string[] = [];

  for (const app of apps) {
    if (!app.resize) {
      continue;
    }

    const client = resolvedApps.get(app.id);
    if (!client) {
      throw new LayoutError(`Resize target missing: ${app.id}`);
    }

    const monitor = monitorsById.get(app.targetMonitor);
    if (!monitor) {
      throw new LayoutError(`Resize monitor missing: ${app.targetMonitor}`);
    }

    const x = resolvePixelOrPercent(
      app.resize.width,
      monitorInnerWidth(monitor),
    );
    const y = resolvePixelOrPercent(
      app.resize.height,
      monitorInnerHeight(monitor),
    );

    commands.push(
      hypr.buildCommand("window", "resize", {
        x,
        y,
        window: selectorForAddress(client.address),
      }),
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

    logStep("> Launching apps.");
    const resolvedApps = await launchMissingApps(hypr, config);

    logStep("> Untabbing everything.");
    await untabEverything(hypr, monitorIds);

    logStep("> Unfloat all windows.");
    await unfloatEverything(hypr, monitorIds);

    logStep("> Moving windows to target monitors.");
    await moveWindowsToAssignedMonitors(hypr, config.apps, resolvedApps);

    logStep("> Sorting windows.");
    await sortWindowsOnMonitors(hypr, config.apps, resolvedApps);

    logStep("> Creating groups.");
    await createGroups(hypr, config.apps, resolvedApps);

    logStep("> Applying resizes.");
    // await applyResizes(hypr, config.apps, resolvedApps);

    const primaryMonitor = monitorIds[0];
    if (primaryMonitor !== undefined) {
      await hypr.command("focus", {
        monitor: primaryMonitor as MonitorSelector,
      });
    }

    logStep("> Layout complete.");
  } finally {
    hypr.close();
  }
}
