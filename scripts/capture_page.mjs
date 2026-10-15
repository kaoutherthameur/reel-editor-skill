#!/usr/bin/env node
// Full-resolution, logged-out capture of a public web page (no account UI, no cursor).
//   node capture_page.mjs <url> <out.png> [--w 1440] [--h 900] [--dpr 2] [--wait 3000] [--dismiss "Keep current"] [--rect "css selector"]
// Uses the system Chrome headless with a throwaway profile (never the creator's logged-in profile).
// --rect prints the CSS-pixel box of matching elements (to align taps / rings / lenses on the screenshot).
import { readdirSync, existsSync, mkdtempSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { join } from "node:path";
const npx = join(homedir(), ".npm/_npx");
const dir = existsSync(npx) && readdirSync(npx).map((d) => join(npx, d, "node_modules/puppeteer-core")).find(existsSync);
if (!dir) { console.error("puppeteer-core not found in ~/.npm/_npx (run any `npx hyperframes` command once)"); process.exit(1); }
const puppeteer = (await import(join(dir, "lib/puppeteer/puppeteer-core.js"))).default;
const a = process.argv.slice(2), url = a[0], out = a[1];
const opt = (k, d) => { const i = a.indexOf(k); return i > 0 ? a[i + 1] : d; };
const b = await puppeteer.launch({ executablePath: "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", headless: "new",
  userDataDir: mkdtempSync(join(tmpdir(), "cap-")) });
const p = await b.newPage();
await p.setViewport({ width: +opt("--w", 1440), height: +opt("--h", 900), deviceScaleFactor: +opt("--dpr", 2) });
await p.goto(url, { waitUntil: "networkidle2", timeout: 60000 });
await new Promise((r) => setTimeout(r, +opt("--wait", 3000)));
const dis = opt("--dismiss");
if (dis) await p.evaluate((t) => { const k = [...document.querySelectorAll("button")].find((x) => x.innerText.includes(t)); k && k.click(); }, dis);
await new Promise((r) => setTimeout(r, 800));
await p.screenshot({ path: out });
const sel = opt("--rect");
if (sel) console.log(JSON.stringify(await p.evaluate((s) => [...document.querySelectorAll(s)].slice(0, 10).map((e) => { const r = e.getBoundingClientRect(); return [r.x, r.y, r.width, r.height]; }), sel)));
await b.close();
console.log("->", out);
