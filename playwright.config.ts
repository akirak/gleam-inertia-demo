import { defineConfig, devices } from "@playwright/test";

const host = "127.0.0.1";
const port = 8010;
const vitePort = 4173;
const baseURL = `http://${host}:${port}`;
const viteOrigin = `http://${host}:${vitePort}`;
const browserExecutablePath = process.env.PLAYWRIGHT_BROWSER_EXECUTABLE_PATH;
const webServer = [
  {
    command: `pnpm dev --host ${host} --port ${vitePort} --strictPort`,
    url: `${viteOrigin}/static/@vite/client`,
    reuseExistingServer: !process.env.CI,
    stdout: "pipe" as const,
    stderr: "pipe" as const,
    timeout: 120 * 1000,
  },
  {
    command: `PORT=${port} DEMO_WEB_ENV=development VITE_DEV_SERVER_ORIGIN=${viteOrigin} gleam run -m main`,
    url: baseURL,
    reuseExistingServer: !process.env.CI,
    stdout: "pipe" as const,
    stderr: "pipe" as const,
    timeout: 120 * 1000,
  },
];

export default defineConfig({
  testDir: "./tests/e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  reporter: process.env.CI ? [["html", { open: "never" }], ["list"]] : "list",
  use: {
    baseURL,
    trace: "on-first-retry",
    ...(browserExecutablePath ? { launchOptions: { executablePath: browserExecutablePath } } : {}),
  },
  projects: [
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
      },
    },
  ],
  ...(process.env.PLAYWRIGHT_NO_WEBSERVER ? {} : { webServer }),
});
