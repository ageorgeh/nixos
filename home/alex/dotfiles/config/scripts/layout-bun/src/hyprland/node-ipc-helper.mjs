import { createConnection } from "node:net";
import { createInterface } from "node:readline";

const [, , mode, socketPath, payload = ""] = process.argv;

if (!mode || !socketPath) {
  console.error("usage: node-ipc-helper.mjs <request|events> <socketPath> [payload]");
  process.exit(1);
}

function requestOnce(targetSocketPath, targetPayload) {
  return new Promise((resolve, reject) => {
    const socket = createConnection({ path: targetSocketPath });
    let response = "";

    socket.setEncoding("utf8");
    socket.on("connect", () => {
      socket.write(targetPayload);
      socket.end();
    });
    socket.on("data", (chunk) => {
      response += chunk;
    });
    socket.on("end", () => {
      resolve(response);
    });
    socket.on("error", (error) => {
      reject(error);
    });
  });
}

if (mode === "request") {
  requestOnce(socketPath, payload)
    .then((response) => {
      process.stdout.write(response);
      process.exit(0);
    })
    .catch((error) => {
      console.error(error.message);
      process.exit(1);
    });
} else if (mode === "request-loop") {
  const reader = createInterface({
    input: process.stdin,
    crlfDelay: Infinity,
  });

  for await (const line of reader) {
    if (line === "") {
      continue;
    }

    try {
      const message = JSON.parse(line);
      const response = await requestOnce(socketPath, message.payload);
      process.stdout.write(
        `${JSON.stringify({ id: message.id, ok: true, response })}\n`,
      );
    } catch (error) {
      const message =
        error instanceof Error ? error.message : String(error);
      let id = null;
      try {
        const parsed = JSON.parse(line);
        id = parsed.id ?? null;
      } catch {}

      process.stdout.write(
        `${JSON.stringify({ id, ok: false, error: message })}\n`,
      );
    }
  }

  process.exit(0);
} else if (mode === "events") {
  const socket = createConnection({ path: socketPath });
  socket.setEncoding("utf8");

  const close = () => {
    socket.destroy();
    process.exit(0);
  };

  process.on("SIGTERM", close);
  process.on("SIGINT", close);

  socket.on("data", (chunk) => {
    process.stdout.write(chunk);
  });
  socket.on("error", (error) => {
    console.error(error.message);
    process.exit(1);
  });
  socket.on("close", () => {
    process.exit(0);
  });
} else {
  console.error(`unknown mode: ${mode}`);
  process.exit(1);
}
