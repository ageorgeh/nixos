import { createConnection } from "node:net";

const [, , mode, socketPath, payload = ""] = process.argv;

if (!mode || !socketPath) {
  console.error("usage: node-ipc-helper.mjs <request|events> <socketPath> [payload]");
  process.exit(1);
}

if (mode === "request") {
  const socket = createConnection({ path: socketPath });
  let response = "";

  socket.setEncoding("utf8");
  socket.on("connect", () => {
    socket.write(payload);
    socket.end();
  });
  socket.on("data", (chunk) => {
    response += chunk;
  });
  socket.on("end", () => {
    process.stdout.write(response);
  });
  socket.on("close", () => {
    process.exit(0);
  });
  socket.on("error", (error) => {
    console.error(error.message);
    process.exit(1);
  });
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
