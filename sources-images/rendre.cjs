// Rend chaque <section class="schema"> de schemas.html en PNG (×2) dans images/.
// Usage : NODE_PATH=<node_modules contenant playwright> node sources-images/rendre.cjs
const { chromium } = require('playwright');
const path = require('path');
(async () => {
  const racine = path.resolve(__dirname, '..');
  const navigateur = await chromium.launch();
  const page = await navigateur.newPage({ deviceScaleFactor: 2, viewport: { width: 1400, height: 1000 } });
  await page.goto('file://' + path.join(__dirname, 'schemas.html'));
  await page.evaluate(() => document.fonts.ready);
  for (const id of await page.$$eval('section.schema', s => s.map(e => e.id))) {
    await page.locator('#' + id).screenshot({ path: path.join(racine, 'images', id + '.png') });
    console.log('images/' + id + '.png');
  }
  await navigateur.close();
})();
