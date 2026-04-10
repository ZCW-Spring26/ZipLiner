// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";

// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

// HTMX is loaded via CDN in the root layout.
// This file adds the CSRF token header to all HTMX requests.
document.addEventListener("DOMContentLoaded", () => {
  // Inject CSRF token into all HTMX requests automatically.
  const csrfToken = document
    .querySelector("meta[name='csrf-token']")
    ?.getAttribute("content");

  if (csrfToken) {
    document.body.setAttribute("hx-headers", JSON.stringify({ "x-csrf-token": csrfToken }));
  }

  // Enable HTMX history support.
  htmx.config.historyCacheSize = 10;
});

// Phoenix LiveSocket (used for LiveDashboard in dev).
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: document.querySelector("meta[name='csrf-token']")?.getAttribute("content") },
});

liveSocket.connect();

window.liveSocket = liveSocket;
