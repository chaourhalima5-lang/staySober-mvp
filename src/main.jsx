import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import App from "./App.jsx";

// ---------------------------------------------------------------------------
// window.storage compatibility shim
// ---------------------------------------------------------------------------
// App.jsx was originally built inside an Anthropic Claude.ai "artifact"
// sandbox, which provides a built-in `window.storage` key-value API for
// persistence. That API does not exist in a real browser or on Vercel.
//
// This shim implements the exact same method signatures using real
// `localStorage`, so every call already in App.jsx (`window.storage.get`,
// `.set`, `.delete`, `.list`) keeps working completely unmodified — not a
// single call site in App.jsx needed to change.
//
// Note on the `shared` parameter: the original API distinguished "shared"
// (visible to all Claude.ai users of an artifact) vs. "personal" storage.
// In a real single-tenant deployment, all storage is already scoped to the
// individual visitor's own browser, so this shim intentionally treats both
// the same way — this is a deliberate, documented simplification, not a
// bug. Session data (Supabase auth tokens) uses only the "personal" path
// already, so this has no visible effect on behavior.
// ---------------------------------------------------------------------------
if (typeof window !== "undefined" && !window.storage) {
  const PREFIX = "staysober_storage:";
  window.storage = {
    async get(key) {
      const raw = localStorage.getItem(PREFIX + key);
      return raw === null ? null : { key, value: raw, shared: false };
    },
    async set(key, value) {
      localStorage.setItem(PREFIX + key, value);
      return { key, value, shared: false };
    },
    async delete(key) {
      localStorage.removeItem(PREFIX + key);
      return { key, deleted: true, shared: false };
    },
    async list(prefix = "") {
      const keys = Object.keys(localStorage)
        .filter((k) => k.startsWith(PREFIX + prefix))
        .map((k) => k.slice(PREFIX.length));
      return { keys, shared: false };
    },
  };
}

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <App />
  </StrictMode>
);
