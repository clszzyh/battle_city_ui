import "../css/app.scss";

import "phoenix_html";
import { Socket } from "phoenix";
import NProgress from "nprogress";
import { LiveSocket } from "phoenix_live_view";
import { GameHook } from "./game";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
if (
  localStorage.theme === "dark" ||
  (!("theme" in localStorage) &&
    window.matchMedia("(prefers-color-scheme: dark)").matches)
) {
  document.querySelector("html").classList.add("dark");
} else {
  document.querySelector("html").classList.remove("dark");
}

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {
    game: GameHook,
  },
  metadata: {
    keydown: (e, el) => {
      return {
        key: e.key,
        metaKey: e.metaKey,
        repeat: e.repeat,
      };
    },
  },
});

window.addEventListener("phx:page-loading-start", (info) => NProgress.start());
window.addEventListener("phx:page-loading-stop", (info) => NProgress.done());

liveSocket.connect();
window.liveSocket = liveSocket;
