#!/usr/bin/env node
// Viewport captures of page sections that animate in on scroll (logged-out headless Chrome, 2x).
//   node capture_sections.mjs <url> <out_prefix> "<heading text 1>" "<heading text 2>" ... [--w 1280] [--h 1000] [--dpr 2] [--offset 80]
// For each text: scroll so the first element whose own text starts with it sits `offset` px below the top,
// wait for reveals, screenshot the viewport -> <out_prefix>-<n>.png. Prints the element box per shot.
import { readdirSync, existsSync, mkdtempSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { join } from "node:path";
const npx = join(homedir(), ".npm/_npx");
const dir = existsSync(npx) && readdirSync(npx).map((d) => join(npx, d, "node_modules/puppeteer-core")).find(existsSync);
if (!dir) { console.error("puppeteer-core not found in ~/.npm/_npx"); process.exit(1); }
const puppeteer = (await import(join(dir, "lib/puppeteer/puppeteer-core.js"))).default;
const a = process.argv.slice(2);
const opt = (k, d) => { const i = a.indexOf(k); if (i < 0) return d; const v = a[i + 1]; a.splice(i, 2); return v; };
const W = +opt("--w", 1280), H = +opt("--h", 1000), DPR = +opt("--dpr", 2), OFF = +opt("--offset", 80);
const [url, pre, ...texts] = a;
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const b = await puppeteer.launch({ executablePath: "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", headless: "new",
  userDataDir: mkdtempSync(join(tmpdir(), "cap-")) });
const p = await b.newPage();
await p.setViewport({ width: W, height: H, deviceScaleFactor: DPR });
await p.goto(url, { waitUntil: "networkidle2", timeout: 60000 });
await sleep(2500);
// dismiss cookie banners (most privacy-preserving choice first)
await p.evaluate(() => { const k = [...document.querySelectorAll("button")].find((x) => /reject|decline|necessary only/i.test(x.innerText)); k && k.click(); });
for (let i = 0; i < texts.length; i++) {
  const box = await p.evaluate((t, off) => {
    const el = [...document.querySelectorAll("h1,h2,h3,h4,p,span,div,button,summary")].find((e) => e.childElementCount < 3 && e.innerText && e.innerText.trim().startsWith(t));
    if (!el) return null;
    const r = el.getBoundingClientRect(); window.scrollBy(0, r.top - off);
    return true;
  }, texts[i], OFF);
  if (!box) { console.log("not found:", texts[i]); continue; }
  await sleep(2200);
  const r = await p.evaluate((t) => { const el = [...document.querySelectorAll("h1,h2,h3,h4,p,span,div,button,summary")].find((e) => e.childElementCount < 3 && e.innerText && e.innerText.trim().startsWith(t)); const q = el.getBoundingClientRect(); return [q.x, q.y, q.width, q.height]; }, texts[i]);
  const out = `${pre}-${i + 1}.png`;
  await p.screenshot({ path: out });
  console.log(out, JSON.stringify(r), texts[i]);
}
await b.close();
