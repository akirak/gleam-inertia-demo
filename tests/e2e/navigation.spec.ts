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
