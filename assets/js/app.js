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

  // Auto-scroll the messages container to the latest message on page load and
  // after every HTMX swap (periodic polling and post-send updates).
  const messagesContainer = document.getElementById("messages-container");
  if (messagesContainer) {
    const scrollToBottom = () => { messagesContainer.scrollTop = messagesContainer.scrollHeight; };
    scrollToBottom();
    messagesContainer.addEventListener("htmx:afterSettle", scrollToBottom);
  }

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

  // Fallback dropdown toggle in case Bootstrap JS doesn't initialize correctly.
  // Only activates if Bootstrap's Dropdown API is unavailable.
  if (!window.bootstrap?.Dropdown) {
    const getDropdownMenu = (toggle) => {
      const menu = toggle.nextElementSibling;
      return menu && menu.classList.contains("dropdown-menu") ? menu : null;
    };

    const closeAllDropdowns = () => {
      document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach((toggle) => {
        const menu = getDropdownMenu(toggle);
        if (menu) {
          menu.classList.remove("show");
          toggle.setAttribute("aria-expanded", "false");
        }
      });
    };

    document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach((toggle) => {
      toggle.addEventListener("click", (e) => {
        e.preventDefault();
        e.stopPropagation();
        const menu = getDropdownMenu(toggle);
        if (menu) {
          const isOpen = menu.classList.contains("show");
          closeAllDropdowns();
          if (!isOpen) {
            menu.classList.add("show");
            toggle.setAttribute("aria-expanded", "true");
          }
        }
      });
    });

    document.addEventListener("click", (e) => {
      if (!e.target.closest(".dropdown-menu") && !e.target.closest('[data-bs-toggle="dropdown"]')) {
        closeAllDropdowns();
      }
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
