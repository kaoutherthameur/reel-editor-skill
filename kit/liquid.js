/* reel-editor kit — liquid glass (Apple "Liquid Glass" look) with metaball merging ("Zac" morph).
 *
 * Glass shapes are rounded boxes combined with a smooth union, so two shapes close together melt into one blob
 * with a liquid neck, then snap apart. The glass refracts what is behind it (lens bend at the rim, chromatic
 * fringe), adds a rim light, an opposite-edge shade and a soft drop shadow.
 *
 * Rule: use only over imagery (face footage, screenshots, photos). Over the empty grid it has nothing to bend.
 *
 * Headless render cannot read <video> into WebGL, so the background is a pre-extracted frame sequence of the
 * region under the glass:  ffmpeg -ss <t0> -t <dur> -i graded.mov -vf crop=W:H:X:Y -q:v 3 frames/f%04d.jpg
 *
 * Usage:
 *   const glass = Reel.liquid({ canvas, size: [W, H], frames: { pattern: i => `frames/f${String(i).padStart(4,"0")}.jpg`, count, fps: 30 },
 *                               shapes: [{x,y,w,h,r,on}, ...], k: 70 });
 *   // tween shape fields with GSAP (x,y = centre, w,h = half size, r = corner radius, on = 0..1 presence), then:
 *   tl.eventCallback("onUpdate", () => glass.render(tl.time()));   // pass t0/t1 in opt to limit it to a window (frames start at t0)
 *   window.__hf.buildReady["liquid"] = glass.ready;
 */
(function () {
  const R = (window.Reel = window.Reel || {});
  const MAX = 4;

  const VS = `#version 300 es
  in vec2 a; void main(){ gl_Position = vec4(a, 0., 1.); }`;

  const FS = `#version 300 es
  precision highp float;
  uniform sampler2D uBg; uniform vec2 uSize;
  uniform vec4 uS[${MAX}]; uniform float uR[${MAX}]; uniform float uOn[${MAX}];
  uniform float uK, uRefr, uBevel, uChroma, uSpec, uTint, uFrost;
  out vec4 o;
  float sdBox(vec2 p, vec2 b, float r){ vec2 q = abs(p) - b + r; return length(max(q, 0.)) + min(max(q.x, q.y), 0.) - r; }
  float smin(float a, float b, float k){ float h = max(k - abs(a - b), 0.) / k; return min(a, b) - h * h * k * 0.25; }
  float map(vec2 p){
    float d = 1e5;
    for (int i = 0; i < ${MAX}; i++) {
      float on = uOn[i]; if (on < 0.001) continue;
      vec2 hb = max(uS[i].zw * on, vec2(0.5));
      float r = min(uR[i] * on, min(hb.x, hb.y));
      float di = sdBox(p - uS[i].xy, hb, r);
      d = d > 9e4 ? di : smin(d, di, uK);
    }
    return d;
  }
  vec3 bg(vec2 p){ return texture(uBg, p / uSize).rgb; }
  void main(){
    vec2 p = vec2(gl_FragCoord.x, uSize.y - gl_FragCoord.y);     // top-left origin, px
    float d = map(p);
    if (d > 0.) {                                                // outside: soft drop shadow only
      float ds = map(p - vec2(0., 12.));
      float sh = (1. - smoothstep(0., 34., ds)) * 0.09;
      o = vec4(0., 0., 0., sh); return;
    }
    vec2 e1 = vec2(1., 0.);
    vec2 g = vec2(map(p + e1.xy) - map(p - e1.xy), map(p + e1.yx) - map(p - e1.yx));
    vec2 n = normalize(g + 1e-6);                                // outward normal
    float e = 1. - clamp(-d / uBevel, 0., 1.);                   // 1 at rim -> 0 inside
    float lens = pow(e, 2.4);
    vec2 base = p - n * lens * uRefr;                            // bend: rim samples from further inside
    float ca = uChroma * lens;
    vec3 col;
    // light frost (5 taps) + chromatic fringe
    vec2 f = vec2(uFrost, 0.);
    col.r = (bg(base - n*ca) + bg(base - n*ca + f.xy) + bg(base - n*ca - f.xy) + bg(base - n*ca + f.yx) + bg(base - n*ca - f.yx)).r / 5.;
    col.g = (bg(base) + bg(base + f.xy) + bg(base - f.xy) + bg(base + f.yx) + bg(base - f.yx)).g / 5.;
    col.b = (bg(base + n*ca) + bg(base + n*ca + f.xy) + bg(base + n*ca - f.xy) + bg(base + n*ca + f.yx) + bg(base + n*ca - f.yx)).b / 5.;
    col = mix(col, vec3(1.), uTint) * 1.06;                      // light milky body, slightly brightened
    vec2 L = normalize(vec2(-0.55, -0.85));                      // light from top-left
    float spec = pow(max(dot(n, L), 0.), 2.) * pow(e, 3.) * uSpec;
    float shade = 0.;                                            // v2: no dark edge (user: dark looks bad)
    float rim = smoothstep(-3.0, -0.6, d) * 0.65;                 // thin bright edge
    col = col + spec + rim - shade;
    float a = smoothstep(0., -1.2, d);
    o = vec4(clamp(col, 0., 1.) * a, a);
  }`;

  R.liquid = function (opt) {
    const cv = opt.canvas, [W, H] = opt.size;
    cv.width = W; cv.height = H;
    const gl = cv.getContext("webgl2", { premultipliedAlpha: true, alpha: true, preserveDrawingBuffer: true });
    const sh = (t, s) => { const x = gl.createShader(t); gl.shaderSource(x, s); gl.compileShader(x); if (!gl.getShaderParameter(x, gl.COMPILE_STATUS)) throw new Error(gl.getShaderInfoLog(x)); return x; };
    const pr = gl.createProgram(); gl.attachShader(pr, sh(gl.VERTEX_SHADER, VS)); gl.attachShader(pr, sh(gl.FRAGMENT_SHADER, FS)); gl.linkProgram(pr); gl.useProgram(pr);
    const buf = gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);
    const loc = gl.getAttribLocation(pr, "a"); gl.enableVertexAttribArray(loc); gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0);
    const U = (n) => gl.getUniformLocation(pr, n);
    const tex = gl.createTexture(); gl.bindTexture(gl.TEXTURE_2D, tex);
    [[gl.TEXTURE_MIN_FILTER, gl.LINEAR], [gl.TEXTURE_MAG_FILTER, gl.LINEAR], [gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE], [gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE]].forEach(([k, v]) => gl.texParameteri(gl.TEXTURE_2D, k, v));
    gl.enable(gl.BLEND); gl.blendFunc(gl.ONE, gl.ONE_MINUS_SRC_ALPHA);
    gl.viewport(0, 0, W, H);

    const P = Object.assign({ k: 70, refr: 26, bevel: 30, chroma: 2.5, spec: 0.7, tint: 0.22, frost: 2.4 }, opt);
    const fr = opt.frames;
    const imgs = [];
    const ready = Promise.all(Array.from({ length: fr.count }, (_, i) => new Promise((res) => {
      const im = new Image(); im.onload = () => res(); im.onerror = () => res(); im.src = fr.pattern(i + 1); imgs.push(im);
    })));
    let lastFrame = -1;

    const t0 = opt.t0 ?? 0, t1 = opt.t1 ?? Infinity;   // active window in composition time; frames start at t0
    function render(tg) {
      if (tg < t0 || tg > t1) { gl.clearColor(0, 0, 0, 0); gl.clear(gl.COLOR_BUFFER_BIT); return; }
      const t = tg - t0;
      const fi = Math.min(fr.count - 1, Math.max(0, Math.round(t * fr.fps)));
      const im = imgs[fi];
      if (im && im.complete && im.naturalWidth && fi !== lastFrame) {
        gl.bindTexture(gl.TEXTURE_2D, tex);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, im);
        lastFrame = fi;
      }
      const S = new Float32Array(MAX * 4), Rr = new Float32Array(MAX), On = new Float32Array(MAX);
      opt.shapes.forEach((s, i) => { S.set([s.x, s.y, s.w, s.h], i * 4); Rr[i] = s.r; On[i] = s.on; });
      gl.uniform4fv(U("uS"), S); gl.uniform1fv(U("uR"), Rr); gl.uniform1fv(U("uOn"), On);
      gl.uniform2f(U("uSize"), W, H); gl.uniform1i(U("uBg"), 0);
      gl.uniform1f(U("uK"), P.k); gl.uniform1f(U("uRefr"), P.refr); gl.uniform1f(U("uBevel"), P.bevel);
      gl.uniform1f(U("uChroma"), P.chroma); gl.uniform1f(U("uSpec"), P.spec); gl.uniform1f(U("uTint"), P.tint); gl.uniform1f(U("uFrost"), P.frost);
      gl.clearColor(0, 0, 0, 0); gl.clear(gl.COLOR_BUFFER_BIT);
      gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    }
    return { render, ready: ready.then(() => render(t0)) };
  };
})();
