// Rend chaque captures/<nom>.txt (sortie réelle de terminal) en images/terminal-<nom>.png.
// Usage : NODE_PATH=<node_modules contenant playwright> node sources-images/rendre-captures.cjs
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const TITRES = {
  doctor: 'hermes doctor · Hermes Agent v0.22.2, image Docker officielle, installation neuve',
  approbations: 'hermes approvals test · avec exemples/config-securite.yaml, Hermes Agent v0.22.2',
};
const echapper = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
function ligne(l) {
  if (l.startsWith('$ ')) return `<span class="invite">$</span> <span class="cmd">${echapper(l.slice(2))}</span>`;
  let h = echapper(l);
  h = h.replace(/(✓)/g, '<span class="ok">$1</span>').replace(/(⚠)/g, '<span class="alerte">$1</span>');
  if (/^(verdict|rule)\s*:/.test(l)) h = `<span class="fort">${h}</span>`;
  if (/^◆/.test(l)) h = `<span class="section">${h}</span>`;
  return h;
}
(async () => {
  const racine = path.resolve(__dirname, '..');
  const navigateur = await chromium.launch();
  const page = await navigateur.newPage({ deviceScaleFactor: 2, viewport: { width: 1200, height: 800 } });
  for (const f of fs.readdirSync(path.join(__dirname, 'captures')).filter(f => f.endsWith('.txt'))) {
    const nom = f.replace(/\.txt$/, '');
    const texte = fs.readFileSync(path.join(__dirname, 'captures', f), 'utf8').replace(/\s+$/, '');
    await page.setContent(`<!doctype html><html><head><meta charset="utf-8">
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=Inter:wght@500&display=swap" rel="stylesheet">
<style>
body{margin:0;padding:24px;background:#ccc}
.term{width:1080px;background:#0A0E1A;border:2px solid #0A0E1A;border-radius:4px;overflow:hidden}
.barre{background:#E8E5DE;color:#0A0E1A;font:500 14px Inter,sans-serif;padding:10px 16px;display:flex;gap:8px;align-items:center}
.barre i{width:11px;height:11px;border-radius:2px;background:#0A0E1A;opacity:.25;display:inline-block}
pre{margin:0;padding:20px 22px;color:#F5F3EE;font:400 14.5px/1.55 'JetBrains Mono',monospace;white-space:pre-wrap}
.invite{color:#D4FF4F;font-weight:700}.cmd{color:#D4FF4F}.ok{color:#D4FF4F}.alerte{color:#F5F3EE;font-weight:700}
.fort{font-weight:700}.section{font-weight:700}
</style></head><body><div class="term"><div class="barre"><i></i><i></i><i></i>&nbsp;${echapper(TITRES[nom] || nom)}</div><pre>${texte.split('\n').map(ligne).join('\n')}</pre></div></body></html>`);
    await page.evaluate(() => document.fonts.ready);
    await page.locator('.term').screenshot({ path: path.join(racine, 'images', `terminal-${nom}.png`) });
    console.log(`images/terminal-${nom}.png`);
  }
  await navigateur.close();
})();
