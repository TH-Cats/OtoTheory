import { test, expect } from '@playwright/test';

const widths = [768, 1024, 1440];
// Chord Progression（旧 /find-key）
const PATH = '/find-key';

for (const w of widths) {
  test(`result visible at width ${w}`, async ({ browser }) => {
    const context = await browser.newContext({ viewport: { width: w, height: 900 } });
    const page = await context.newPage();
    await page.goto(PATH);

    const result = page.locator('#result');
    await expect(result).toBeVisible();

    const box = await result.boundingBox();
    expect(box?.width || 0).toBeGreaterThan(320);
    expect(box?.height || 0).toBeGreaterThan(24);

    const cls = await result.getAttribute('class');
    expect(cls || '').not.toMatch(/\b(hidden|invisible|opacity-0)\b/);

    await context.close();
  });
}


