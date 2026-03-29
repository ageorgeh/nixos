#!/usr/bin/env bun

import { runManagedLayout } from "./src/layout";

runManagedLayout().catch((error: unknown) => {
  const message = error instanceof Error ? error.stack ?? error.message : String(error);
  console.error(message);
  process.exitCode = 1;
});
