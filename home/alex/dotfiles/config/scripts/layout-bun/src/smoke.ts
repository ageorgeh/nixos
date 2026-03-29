import { setTimeout as sleep } from "node:timers/promises";

import { HyprlandClient } from "./hyprland/client";

async function waitForCustomEvents(
  hypr: HyprlandClient,
  expected: readonly string[],
  trigger: () => Promise<unknown>,
): Promise<string[]> {
  const seen: string[] = [];
  const controller = new AbortController();

  try {
    const waiter = (async () => {
      for await (const event of hypr.events(controller.signal)) {
        if (event.name !== "custom") {
          continue;
        }

        seen.push(event.data);
        if (expected.every((value) => seen.includes(value))) {
          return seen;
        }
      }

      throw new Error("Event stream closed before all custom events arrived.");
    })();

    await sleep(100);
    await trigger();

    return await Promise.race([
      waiter,
      sleep(2_000).then(() => {
        throw new Error(
          `Timed out waiting for custom events: ${expected.join(", ")}`,
        );
      }),
    ]);
  } finally {
    controller.abort();
  }
}

async function main(): Promise<void> {
  const hypr = new HyprlandClient();
  const monitors = await hypr.monitors();
  const clients = await hypr.clients();
  const activeWindow = await hypr.activeWindow();
  const workspaces = await hypr.workspaces();

  const singleEventRoundTrip = await waitForCustomEvents(hypr, ["codex-smoke"], async () => {
    await hypr.dispatchRaw("event", "codex-smoke");
  });

  let batchResponses: string[] = [];
  const batchEventRoundTrip = await waitForCustomEvents(
    hypr,
    ["codex-batch-1", "codex-batch-2"],
    async () => {
      batchResponses = await hypr.batch([
        "dispatch event codex-batch-1",
        "dispatch event codex-batch-2",
      ]);
    },
  );

  console.log(
    JSON.stringify(
      {
        requestSocketPath: hypr.requestSocketPath,
        eventSocketPath: hypr.eventSocketPath,
        monitorCount: monitors.length,
        monitorNames: monitors.map((monitor) => monitor.name),
        clientCount: clients.length,
        activeWindow: activeWindow
          ? {
              address: activeWindow.address,
              class: activeWindow.class,
              title: activeWindow.title,
              monitor: activeWindow.monitor,
            }
          : null,
        workspaceCount: workspaces.length,
        eventRoundTrip: singleEventRoundTrip,
        batchResponses,
        batchEventRoundTrip,
      },
      null,
      2,
    ),
  );
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.stack ?? error.message : String(error));
  process.exitCode = 1;
});
