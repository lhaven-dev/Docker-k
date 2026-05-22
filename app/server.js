const http = require("http");

const PORT = Number(process.env.PORT) || 3000;
const APP_NAME = process.env.APP_NAME || "hello-world-tp";
const ENVIRONMENT = process.env.ENVIRONMENT || "development";

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok" }));
    return;
  }

  res.writeHead(200, { "Content-Type": "text/plain; charset=utf-8" });
  res.end(`Hello World\n\nApp: ${APP_NAME}\nEnvironment: ${ENVIRONMENT}\n`);
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`Server listening on http://0.0.0.0:${PORT}`);
});
