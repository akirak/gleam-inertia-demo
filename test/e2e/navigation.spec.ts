import { expect, test } from "@playwright/test";

test("renders the home page and navigates to the about page", async ({ page }) => {
  await page.goto("/");

  await expect(page).toHaveTitle("Demo Home");
  await expect(page.getByRole("heading", { level: 1, name: "Demo" })).toBeVisible();
  await expect(page.getByText("Demo Web")).toBeVisible();

  await page.getByRole("link", { name: "About" }).click();

  await expect(page).toHaveURL("/about");
  await expect(page).toHaveTitle("About");
  await expect(page.getByRole("heading", { level: 1, name: "About" })).toBeVisible();
  await expect(page.getByText("System Version:")).toBeVisible();
});

test("renders a dynamic greet route", async ({ page }) => {
  await page.goto("/greet/Playwright");

  await expect(page).toHaveTitle("Greet");
  await expect(
    page.getByRole("heading", { level: 1, name: "Hey there, Playwright!" }),
  ).toBeVisible();
});

test("loads deferred props after the initial protocol page render", async ({ page }) => {
  await page.goto("/protocol/deferred");

  await expect(page).toHaveTitle("Deferred Props");
  await expect(page.getByTestId("permissions-list")).toContainText("read:reports");
  await expect(page.getByTestId("analytics-panel")).toContainText("128");
  await expect(page.getByTestId("protocol-metadata")).toContainText('"deferredProps"');
});

test("rescues a deferred prop and retries it on demand", async ({ page }) => {
  await page.goto("/protocol/deferred-rescue");
  await expect(page.getByTestId("rescued-state")).toContainText("rescued");
  await expect(page.getByTestId("protocol-metadata")).toContainText('"rescuedProps"');

  await page.getByTestId("retry-permissions").click();
  await expect(page.getByTestId("rescued-permissions-list")).toContainText("billing:refund");
});

test("merges appended, prepended, and deep-merged props on partial reload", async ({ page }) => {
  await page.goto("/protocol/merge");

  await expect(page.getByTestId("merge-posts")).toContainText("Instrument page object payloads");
  await expect(page.getByTestId("merge-summary")).toContainText("Initial batch");

  await page.getByTestId("merge-next-batch").click();

  await expect(page.getByTestId("merge-summary")).toContainText("Merged batch");
  await expect(page.getByTestId("merge-posts")).toContainText("Document protocol edge cases");
  await expect(page.getByTestId("merge-posts")).toContainText("status=updated");

  const alerts = page.getByTestId("merge-alerts").locator("li");
  await expect(alerts).toHaveCount(2);
  await expect(alerts.first()).toContainText("Prepended alert");
  await expect(page.getByTestId("protocol-metadata")).toContainText('"matchPropsOn"');
});

test("appends paginated results using scroll props metadata", async ({ page }) => {
  await page.goto("/protocol/scroll");

  const posts = page.getByTestId("scroll-posts").locator("li");

  await expect(posts).toHaveCount(2);
  await expect(page.getByTestId("scroll-current-page")).toContainText("1");

  await page.getByTestId("scroll-load-next").click();
  await expect(posts).toHaveCount(4);
  await expect(page.getByTestId("scroll-current-page")).toContainText("2");
  await expect(page.getByTestId("scroll-next-page")).toContainText("3");

  await page.getByTestId("scroll-load-next").click();
  await expect(posts).toHaveCount(6);
  await expect(page.getByTestId("scroll-current-page")).toContainText("3");
  await expect(page.getByTestId("scroll-next-page")).toContainText("none");
});

test("reuses a once prop across pages when the server omits it on the follow-up visit", async ({
  page,
}) => {
  await page.goto("/protocol/once/source");

  const token = (await page.getByTestId("once-source-token").textContent())?.trim();
  expect(token).toBe("catalog-snapshot-source-2026-05-24");

  await page.getByTestId("visit-once-target").click();

  await expect(page.getByTestId("once-target-token")).toHaveText(token ?? "");
  await expect(page.getByTestId("protocol-metadata")).toContainText('"onceProps"');
});
