/* reel-editor kit — motion grammar. Direction rule: everything enters from the RIGHT and exits to the LEFT. */
(function () {
  const TRAVEL = 1150;
  const MOVE = "power2.inOut";   // v2: soft start, glide, soft landing
  const R = (window.Reel = window.Reel || {});

  /** Scene swap: `outs` leave to the left, `ins` arrive from the right, same ease, overlapped. */
  R.conveyor = function (tl, outs, ins, at, o = {}) {
    const d = o.duration ?? 1.0;                 // v2: slower, smooth (was 0.5)
    const outsA = [].concat(outs || []), insA = [].concat(ins || []);
    if (outsA.length) tl.fromTo(outsA, { x: 0 }, { x: -TRAVEL, duration: d, ease: MOVE }, at);
    if (insA.length) tl.fromTo(insA, { x: TRAVEL }, { x: 0, duration: d, ease: MOVE, stagger: o.stagger ?? 0.06 }, at + (o.lag ?? 0.06));
    const all = outsA.concat(insA);
    if (all.length && !o.noDip)                  // gentle depth dip while travelling
      tl.fromTo(all, { scale: 1 }, { scale: 0.96, duration: d / 2, ease: "sine.inOut", yoyo: true, repeat: 1, immediateRender: false }, at);
    if (all.length && !o.noBlur)                 // light motion blur peak
      tl.fromTo(all, { filter: "blur(0px)" }, { filter: "blur(3px)", duration: d / 2, ease: "sine.in", yoyo: true, repeat: 1, immediateRender: false }, at);
    if (o.grid) tl.to(o.grid[0], { x: o.grid[1], duration: d + 0.15, ease: MOVE }, at);
  };

  /** Element entrance inside a scene: from the right, unblur. */
  R.enter = function (tl, els, at, o = {}) {
    tl.fromTo(els, { x: o.dx ?? 90, opacity: 0, filter: "blur(10px)" },
      { x: 0, opacity: 1, filter: "blur(0px)", duration: o.duration ?? 0.75, ease: o.ease ?? "power3.out", stagger: o.stagger ?? 0.07 }, at);
  };

  /** Element exit inside a scene: to the left. */
  R.exit = function (tl, els, at, o = {}) {
    tl.to(els, { x: -(o.dx ?? 90), opacity: 0, filter: "blur(8px)", duration: o.duration ?? 0.5, ease: "power2.inOut", stagger: o.stagger ?? 0.04 }, at);
  };

  /** Slow constant drift of the grid (seek-safe linear tween over the whole video). */
  R.drift = function (tl, grid, total) {
    tl.fromTo(grid, { x: 0 }, { x: -total * 14, duration: total, ease: "none" }, 0);
  };
})();
