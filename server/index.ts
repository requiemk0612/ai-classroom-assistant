import next from "next";
import { createServer } from "http";
import { Server } from "socket.io";
import { parse } from "url";
import { registerSocketHandlers } from "./socket";

const dev = process.env.NODE_ENV !== "production";
const host = "0.0.0.0";
const port = Number(process.env.PORT ?? 3000);
const app = next({ dev, hostname: host, port });
const handle = app.getRequestHandler();

app.prepare().then(() => {
  const httpServer = createServer((req, res) => {
    const parsedUrl = parse(req.url ?? "", true);
    handle(req, res, parsedUrl);
  });

  const io = new Server(httpServer, {
    path: "/api/socket/io"
  });

  registerSocketHandlers(io);

  httpServer.listen(port, host, () => {
    console.log(`Demo server ready at http://${host}:${port}`);
  });
});
