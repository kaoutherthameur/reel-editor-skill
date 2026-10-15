/* reel-editor kit — caption engine.
 * Input: groups = [{ start, end, words: [{ t, text, mk? }] }]  (times in seconds, from transcript.fixed.json)
 * Modes: "strip" (glass strip in the caption band, TALK / TALK+UI) and "kin" (big kinetic words on the SPLIT stage).
 * Words enter right -> left (RTL reading order), 40 ms stagger, rise + unblur; the bordo marker swipes in after its word lands.
 * Group exit: slide left + fade. Each group is hard-hidden after its exit so nothing lingers when seeking.
 */
(function () {
  const R = (window.Reel = window.Reel || {});

  R.captions = function (tl, host, groups, o = {}) {
    const mode = o.mode || "strip";
    groups.forEach((g, gi) => {
      const box = document.createElement("div");
      box.className = mode === "kin" ? "kin" : "cap";
      if (mode === "kin") box.style.top = (o.top ?? 160) + "px";
      const inner = document.createElement("div");
      inner.className = mode === "kin" ? "kin-in" : "strip glass plain";
      g.words.forEach((w) => {
        const s = document.createElement("span");
        s.className = "w" + (w.mk ? " mk" : "");
        s.textContent = w.text;
        if (w.mk) s.style.setProperty("--mk", 0);
        inner.appendChild(s);
        inner.appendChild(document.createTextNode(" "));
      });
      box.appendChild(inner);
      host.appendChild(box);
      const ws = inner.querySelectorAll(".w");
      const t0 = g.start;
      tl.set(box, { opacity: 1 }, 0);
      tl.set(box, { autoAlpha: 0 }, 0);
      tl.set(box, { autoAlpha: 1 }, t0 - 0.02);
      if (mode === "strip") tl.fromTo(inner, { x: 40, opacity: 0 }, { x: 0, opacity: 1, duration: 0.25, ease: "power2.out" }, t0 - 0.02);
      ws.forEach((el, i) => {
        const at = Math.max(t0, g.words[i].t ?? t0 + i * 0.04);
        tl.fromTo(el, { x: 26, y: 14, opacity: 0, filter: "blur(6px)" },
          { x: 0, y: 0, opacity: 1, filter: "blur(0px)", duration: 0.3, ease: "power3.out" }, at);
        if (g.words[i].mk) tl.fromTo(el, { "--mk": 0 }, { "--mk": 1, duration: 0.22, ease: "power2.out" }, at + 0.18);
      });
      const out = g.end;
      tl.to(inner, { x: -60, opacity: 0, duration: 0.18, ease: "power2.in" }, out - 0.2);
      tl.set(box, { autoAlpha: 0 }, out - 0.01);
    });
  };

  /** Chunk transcript words (from transcript.fixed.json chunks) into groups of up to `max` words, breaking on pauses. */
  R.groupWords = function (words, o = {}) {
    const max = o.max ?? 4, gap = o.gap ?? 0.45, hold = o.hold ?? 0.15;
    const out = []; let cur = null;
    words.forEach((w, i) => {
      const prev = words[i - 1];
      if (!cur || cur.words.length >= max || (prev && w.start - prev.end > gap)) {
        cur = { start: w.start, words: [] }; out.push(cur);
      }
      cur.words.push({ t: w.start, text: w.text, mk: w.mk });
      cur.end = w.end + hold;
    });
    out.forEach((g, i) => { if (out[i + 1]) g.end = Math.min(g.end, out[i + 1].start - 0.02); });
    return out;
  };
})();
