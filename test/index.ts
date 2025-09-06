import { readdirSync, statSync } from "fs";
import type { Server } from "bun";

const server: Server = Bun.serve({
  port: 3000,

  fetch(req: Request): Response | Promise<Response> {
    const path = new URL(req.url).pathname.slice(1) || ".";

    try {
      if (statSync(path).isDirectory()) {
        const items = readdirSync(path);
        return new Response(
          items
            .map((item) => `<a href="/${path}/${item}">${item}</a><br>`)
            .join(""),
          { headers: { "Content-Type": "text/html" } },
        );
      }
      return new Response(Bun.file(path));
    } catch {
      return new Response("Not found", { status: 404 });
    }
  },
});

console.log("Server running at http://localhost:3000");
