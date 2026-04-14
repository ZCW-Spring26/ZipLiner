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

  // Fallback hamburger toggle in case Bootstrap JS doesn't initialize correctly.
  // Only activates if Bootstrap's Collapse API is unavailable.
  // DOMContentLoaded fires after all deferred scripts (including Bootstrap), so this
  // check reliably reflects whether Bootstrap loaded successfully.
  if (!window.bootstrap?.Collapse) {
    document.querySelectorAll(".navbar-toggler").forEach((toggler) => {
      toggler.addEventListener("click", () => {
        const targetId = toggler.getAttribute("data-bs-target");
        const target = targetId ? document.querySelector(targetId) : null;
        if (target) {
          target.classList.toggle("show");
          toggler.setAttribute("aria-expanded", String(target.classList.contains("show")));
        }
      });
    });
  }
});

// Phoenix LiveSocket (used for LiveDashboard in dev).
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: document.querySelector("meta[name='csrf-token']")?.getAttribute("content") },
});

liveSocket.connect();

window.liveSocket = liveSocket;
