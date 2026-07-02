import { defineConfig } from "@solidjs/start/config";

export default defineConfig({
  root: ".",
  nitro: {
    compatibilityDate: "2024-09-19",
    preset: "cloudflare_module",
    cloudflare: {
      nodeCompat: true,
    },
  },
  server: {
    allowedHosts: true,
  },
  build: {
    rollupOptions: {
      input: "index.html",
      external: ["cloudflare:workers"],
    },
    minify: false,
  },
});