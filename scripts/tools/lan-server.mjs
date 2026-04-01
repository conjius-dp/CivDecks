import { createServer } from "http";
import { readFile, stat } from "fs/promises";
import { join, extname } from "path";

const PORT = 8060;
const DIR = join(import.meta.dirname, "../../build/web");
const RELOAD_FILE = join(import.meta.dirname, "../../build/.reload");

const MIME = {
  ".html": "text/html",
  ".js": "application/javascript",
  ".mjs": "application/javascript",
  ".wasm": "application/wasm",
  ".pck": "application/octet-stream",
  ".png": "image/png",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".css": "text/css",
  ".json": "application/json",
};

const DEV_SCRIPTS = `<script>
(function(){
  // Live reload via SSE
  function connect() {
    var es = new EventSource("/__reload");
    es.onmessage = function(e) {
      if (e.data === "reload") location.reload();
    };
    es.onerror = function() {
      es.close();
      setTimeout(connect, 2000);
    };
  }
  if (document.readyState === "complete") connect();
  else window.addEventListener("load", connect);

  // Skip loading animation on localhost — hide splash as soon as canvas renders
  var check = setInterval(function() {
    var canvas = document.querySelector("canvas");
    if (!canvas || canvas.width < 100) return;
    try {
      var gl = canvas.getContext("webgl2") || canvas.getContext("webgl");
      if (!gl) return;
      var px = new Uint8Array(4);
      gl.readPixels(canvas.width/2|0, canvas.height/2|0, 1, 1, gl.RGBA, gl.UNSIGNED_BYTE, px);
      if (px[0] === 0 && px[1] === 0 && px[2] === 0) return;
    } catch(e) { return; }
    clearInterval(check);
    ["#status", ".progress-fill"].forEach(function(sel) {
      var el = document.querySelector(sel);
      if (el) { el.style.transition = "none"; el.style.display = "none"; }
    });
  }, 50);

  // Also hide splash immediately if WASM is cached (fast start)
  setTimeout(function() {
    var splash = document.getElementById("status-splash");
    if (splash) { splash.style.animation = "none"; splash.style.opacity = "1"; }
    var fill = document.querySelector(".progress-fill-inner");
    if (fill) { fill.style.animation = "none"; fill.style.transform = "scaleX(1)"; }
  }, 100);
})();
</script>`;

// --- SSE live reload ---

let reloadClients = [];
let lastReloadMtime = 0;

setInterval(async () => {
  try {
    const s = await stat(RELOAD_FILE);
    const mtime = s.mtimeMs;
    if (mtime > lastReloadMtime && lastReloadMtime > 0) {
      reloadClients.forEach(r => r.write("data: reload\n\n"));
    }
    lastReloadMtime = mtime;
  } catch {}
}, 500);

function handleSSE(req, res) {
  res.writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    "Connection": "keep-alive",
    "Cross-Origin-Resource-Policy": "same-origin",
  });
  res.write("data: connected\n\n");
  reloadClients.push(res);
  req.on("close", () => {
    reloadClients = reloadClients.filter(c => c !== res);
  });
}

// --- ETag caching ---

async function getETag(filePath) {
  const s = await stat(filePath);
  return `"${s.mtimeMs.toString(36)}-${s.size.toString(36)}"`;
}

// --- COOP/COEP headers ---

function setCrossOriginHeaders(req, res) {
  const ua = req.headers["user-agent"] || "";
  const isSafari = ua.includes("Safari") && !ua.includes("Chrome");
  if (!isSafari) {
    res.setHeader("Cross-Origin-Opener-Policy", "same-origin");
    res.setHeader("Cross-Origin-Embedder-Policy", "require-corp");
  }
  res.setHeader("Cross-Origin-Resource-Policy", "cross-origin");
}

// --- Request handler ---

const server = createServer(async (req, res) => {
  if (req.url === "/__reload") return handleSSE(req, res);

  const url = req.url === "/" ? "/index.html" : req.url.split("?")[0];
  const filePath = join(DIR, url);

  setCrossOriginHeaders(req, res);

  try {
    const etag = await getETag(filePath);
    if (req.headers["if-none-match"] === etag) {
      res.writeHead(304);
      res.end();
      return;
    }

    let data = await readFile(filePath);
    const ext = extname(filePath);

    // HTML: inject reload script, no cache
    if (ext === ".html") {
      data = Buffer.from(
        data.toString().replace("</head>", DEV_SCRIPTS + "</head>")
      );
      res.writeHead(200, {
        "Content-Type": "text/html",
        "Cache-Control": "no-cache",
      });
      res.end(data);
      return;
    }

    // All other files: cache with ETag
    res.writeHead(200, {
      "Content-Type": MIME[ext] || "application/octet-stream",
      "ETag": etag,
      "Cache-Control": "max-age=31536000, immutable",
    });
    res.end(data);
  } catch {
    res.writeHead(404);
    res.end("Not found");
  }
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`LAN server: http://0.0.0.0:${PORT} (live reload + cache)`);
});
