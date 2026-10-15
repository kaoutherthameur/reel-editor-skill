<!doctype html>
<html lang="ar">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=1080, height=1920" />
  <title>prompt-library</title>
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
  <link rel="stylesheet" href="kit/theme.css" />
  <link rel="stylesheet" href="kit/glass.css" />
  <style>
    @font-face { font-family: "Plex Arabic"; src: url("kit/fonts/plex-arabic-arabic-500.woff2") format("woff2"); font-weight: 500; unicode-range: U+0600-06FF, U+0750-077F, U+08A0-08FF, U+FB50-FDFF, U+FE70-FEFF; }
    @font-face { font-family: "Plex Arabic"; src: url("kit/fonts/plex-arabic-latin-500.woff2") format("woff2"); font-weight: 500; unicode-range: U+0000-00FF, U+2000-206F; }
    @font-face { font-family: "Plex Arabic"; src: url("kit/fonts/plex-arabic-arabic-700.woff2") format("woff2"); font-weight: 700; unicode-range: U+0600-06FF, U+0750-077F, U+08A0-08FF, U+FB50-FDFF, U+FE70-FEFF; }
    @font-face { font-family: "Plex Arabic"; src: url("kit/fonts/plex-arabic-latin-700.woff2") format("woff2"); font-weight: 700; unicode-range: U+0000-00FF, U+2000-206F; }
    @font-face { font-family: "Hook Latin"; src: url("kit/fonts/anton-latin-400.woff2") format("woff2"); font-weight: 400; }
    @font-face { font-family: "Hook Arabic"; src: url("kit/fonts/alexandria-arabic-900.woff2") format("woff2"); font-weight: 900; }

    #root { position: relative; width: 100%; height: 100%; overflow: hidden; }
    .layer { position: absolute; inset: 0; }

    /* face rig */
    #rig { position: absolute; inset: 0; }
    #roomClip { position: absolute; inset: 0; clip-path: inset(0px 0px 0px 0px round 0px); }
    #roomClip video, #subjWrap video { position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; }
    #subjWrap { position: absolute; inset: 0; opacity: 0; }
    #cardShadow { position: absolute; left: 0; right: 0; top: 995px; bottom: 0; border-radius: 56px; opacity: 0;
      box-shadow: 0 -10px 70px rgba(60, 20, 10, 0.22), 0 30px 80px rgba(60, 20, 10, 0.12); }
    #cardEdge { position: absolute; left: 0; right: 0; top: 995px; bottom: -4px; border-radius: 56px; opacity: 0;
      border: 4px solid rgba(245, 218, 191, 0.95); }

    /* hook */
    #hookBack { position: absolute; left: 60px; right: 120px; top: 200px; text-align: center; color: var(--cream); }
    #hookBack .k1 { font-family: "Hook Arabic"; font-weight: 900; font-size: 100px; line-height: 1.25; direction: rtl; text-shadow: 0 6px 28px rgba(0,0,0,.3); }
    #hookBack .k2 { font-family: "Hook Latin"; font-size: 250px; line-height: 0.95; letter-spacing: 0.005em; margin-top: 14px; text-shadow: 0 10px 40px rgba(0,0,0,.28); }
    #hookFront { position: absolute; left: 640px; top: 700px; }
    #hookFront .pill { font-family: "Plex Arabic"; font-weight: 500; font-size: 42px; letter-spacing: 0.14em; color: var(--cream); background: var(--bordo); padding: 10px 24px 12px; border-radius: 14px; box-shadow: 0 14px 30px rgba(0,0,0,.22); }

    /* browser acrylic (screenshots) */
    .browser { position: absolute; border-radius: 30px; padding: 16px 16px 18px; }
    .browser .bar { display: flex; align-items: center; gap: 10px; height: 26px; padding: 0 6px; }
    .browser .dot { width: 13px; height: 13px; border-radius: 50%; background: rgba(15,61,58,.25); }
    .browser .url { margin-left: 14px; font-family: "Plex Arabic"; font-weight: 500; font-size: 22px; color: var(--ink); }
    .browser .shot { position: relative; margin-top: 10px; border-radius: 16px; overflow: hidden; }
    .browser .shot img { display: block; width: 100%; }
    #browser { left: 170px; top: 340px; width: 720px; }

    /* SPLIT stage: 3D folder */
    #folderStage { position: absolute; left: 0; right: 0; top: 320px; height: 560px; perspective: 1600px; perspective-origin: 50% 45%; }
    #folder { position: absolute; left: 310px; top: 150px; width: 460px; height: 330px; transform-style: preserve-3d; }
    #folder .back { position: absolute; inset: 0; border-radius: 26px; background: linear-gradient(170deg, #efdcc6, #e4c8a8);
      box-shadow: inset 0 0 0 2px rgba(255,255,255,.7), 0 34px 70px rgba(60,20,10,.22); }
    #folder .card { position: absolute; bottom: 40px; width: 165px; height: 215px; border-radius: 18px; object-fit: cover;
      box-shadow: 0 16px 34px rgba(40,10,5,.25); border: 2px solid rgba(255,255,255,.85); transform-origin: 50% 100%; }
    #cL { left: 60px; } #cC { left: 148px; } #cR { left: 236px; }
    #folder .front { position: absolute; left: 0; bottom: 0; width: 460px; height: 238px; transform-origin: 50% 100%;
      clip-path: path("M18,0 H158 Q166,0 170,6 L198,37 Q202,43 210,43 H442 Q460,43 460,61 V220 Q460,238 442,238 H18 Q0,238 0,220 V18 Q0,0 18,0 Z");
      background: linear-gradient(125deg, rgba(255,255,255,0) 30%, rgba(255,255,255,.5) 42%, rgba(255,255,255,0) 52%),
                  linear-gradient(160deg, rgba(255,250,244,.86), rgba(245,218,191,.84));
      backdrop-filter: blur(10px) saturate(1.1); -webkit-backdrop-filter: blur(10px) saturate(1.1); }
    #folder .front svg { position: absolute; inset: 0; }
    #folder .label { position: absolute; left: 26px; bottom: 22px; display: flex; align-items: center; gap: 14px; }
    #folder .badge { width: 46px; height: 46px; border-radius: 12px; background: var(--bordo); color: var(--cream); display: grid; place-items: center;
      font-family: "Plex Arabic"; font-weight: 700; font-size: 22px; }
    #folder .word { font-family: "Hook Latin"; font-size: 58px; line-height: 1; color: var(--green); letter-spacing: 0.02em; }
    #folder .sub { position: absolute; right: 26px; bottom: 28px; font-family: "Plex Arabic"; font-weight: 500; font-size: 22px; color: var(--ink-soft); }

    /* SPLIT stage (beat 7): search field */
    #search { position: absolute; left: 150px; top: 560px; width: 780px; height: 116px; border-radius: 58px; display: flex; align-items: center; gap: 22px; padding: 0 40px; }
    #search svg { width: 46px; height: 46px; flex: none; }
    #search .ph { font-family: "Plex Arabic"; font-weight: 500; font-size: 40px; color: rgba(15,61,58,.55); }

    /* EXPLAIN 1: cover-flow + prompt */
    #explain, #ex2, #ex3, #ex4 { overflow: hidden; }
    #carousel { position: absolute; left: 0; right: 0; top: 300px; height: 640px; perspective: 1600px; }
    .cv { position: absolute; left: 340px; top: 30px; width: 400px; height: 560px; border-radius: 44px; overflow: hidden;
      box-shadow: 0 34px 70px rgba(0,0,0,.35); border: 1.5px solid rgba(245,218,191,.25); }
    .cv img { width: 100%; height: 100%; object-fit: cover; display: block; }
    #prompt { position: absolute; left: 90px; width: 840px; top: 900px; padding: 26px 32px 30px; border-radius: 30px; color: var(--cream); }
    .phd { display: flex; justify-content: space-between; align-items: center; font-family: "Plex Arabic"; font-weight: 500; font-size: 28px; opacity: .75; }
    .phd .cp { background: var(--bordo); color: var(--cream); font-size: 24px; padding: 8px 20px; border-radius: 20px; opacity: 1; }
    .tx { font-family: "Plex Arabic"; font-weight: 500; font-size: 31px; line-height: 1.38; margin-top: 12px; }
    .ln { display: block; }
    #prompt .txw { position: relative; height: 128px; margin-top: 12px; }
    #prompt .txw .tx { position: absolute; left: 0; right: 0; top: 0; margin-top: 0; }

    /* EXPLAIN 2: home page tap, then the card wall (ref-02) */
    #home { left: 90px; top: 430px; width: 900px; }
    #navHl { position: absolute; left: 237px; top: 15px; width: 104px; height: 27px; border-radius: 9px; border: 3px solid var(--cream); box-shadow: 0 0 0 3px var(--bordo); opacity: 0; }
    .tap { position: absolute; width: 56px; height: 56px; margin: -28px 0 0 -28px; border-radius: 50%; background: rgba(245,218,191,.55); border: 3px solid rgba(255,255,255,.95); opacity: 0; }
    #tapHome { left: 289px; top: 28px; }
    #wall { position: absolute; inset: 0; }
    .col { position: absolute; top: 0; width: 520px; }
    #colL { left: -310px; } #colC { left: 280px; } #colR { left: 870px; }
    .wc { position: absolute; left: 0; width: 520px; height: 560px; border-radius: 36px; overflow: hidden; background: #0b2e2b;
      box-shadow: 0 30px 60px rgba(0,0,0,.35), inset 0 0 0 1.5px rgba(245,218,191,.3); }
    .wc img, .wc video { position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; }
    .wc .play { position: absolute; right: 22px; top: 22px; width: 58px; height: 58px; border-radius: 50%; background: rgba(15,61,58,.55);
      border: 1.5px solid rgba(245,218,191,.6); display: grid; place-items: center; }
    .wc .play svg { width: 22px; height: 22px; }

    /* EXPLAIN 3: search pill + card wheel (ref-03) + magnifier */
    #spill { position: absolute; left: 190px; top: 250px; width: 700px; height: 104px; border-radius: 52px; display: flex; align-items: center; gap: 22px; padding: 0 36px; transform-origin: 50% 50%; }
    #spill svg { width: 42px; height: 42px; flex: none; }
    #spill .q { font-family: "Plex Arabic"; font-weight: 500; font-size: 44px; color: var(--cream); white-space: nowrap; direction: ltr; }
    #spill .caret { display: inline-block; width: 3px; height: 46px; background: var(--cream); margin-left: 4px; vertical-align: middle; }
    #wheel { position: absolute; inset: 0; transform-origin: 540px 1660px; }
    .wh { position: absolute; left: 400px; top: 590px; width: 280px; height: 380px; border-radius: 26px; overflow: hidden; transform-origin: 140px 1070px;
      box-shadow: 0 20px 40px rgba(0,0,0,.35); border: 1.5px solid rgba(245,218,191,.3); }
    .wh img { width: 100%; height: 100%; object-fit: cover; display: block; }
    #results { left: 130px; top: 230px; width: 820px; }
    #pickRing { position: absolute; left: 149px; top: 353px; width: 267px; height: 331px; border-radius: 14px; border: 6px solid var(--cream); box-shadow: 0 0 0 4px var(--bordo); opacity: 0; transform-origin: 50% 50%; }
    #lens { position: absolute; left: 0; top: 0; width: 330px; height: 330px; opacity: 0; }
    #lens .in { position: absolute; left: 20px; top: 20px; width: 220px; height: 220px; border-radius: 50%; overflow: hidden; }
    #lens .in img { position: absolute; left: -77px; top: -54px; width: 376px; height: 472px; object-fit: cover; }
    #lens svg { position: absolute; inset: 0; }

    /* TALK+UI beat 9: detail card */
    #detail { position: absolute; left: 90px; top: 210px; width: 900px; padding: 22px; border-radius: 34px; display: flex; gap: 26px; }
    #detail .im { position: relative; width: 236px; height: 295px; flex: none; border-radius: 20px; overflow: hidden; }
    #detail .im img { width: 100%; height: 100%; object-fit: cover; display: block; }
    #detail .tx { font-size: 27px; line-height: 1.42; color: var(--ink); margin-top: 10px; }
    #detail .phd { color: var(--ink); }
    #tapDet { left: 118px; top: 150px; }

    /* EXPLAIN 4: use it, swap the hat for the product, generate */
    .pcard { position: absolute; top: 240px; width: 300px; height: 375px; border-radius: 30px; overflow: hidden; box-shadow: 0 30px 60px rgba(0,0,0,.35); border: 1.5px solid rgba(245,218,191,.3); }
    .pcard img { width: 100%; height: 100%; object-fit: cover; display: block; }
    #orig { left: 110px; }
    #slot { left: 670px; background: rgba(245,218,191,.06); border: 2px dashed rgba(245,218,191,.4); box-shadow: none; display: grid; place-items: center; }
    #slot .sp { font-family: "Plex Arabic"; font-weight: 500; font-size: 30px; color: rgba(245,218,191,.7); letter-spacing: .1em; }
    #result { left: 670px; }
    #prod { position: absolute; left: 445px; top: 335px; width: 190px; height: 190px; border-radius: 50%; overflow: hidden; border: 5px solid var(--cream); box-shadow: 0 20px 40px rgba(0,0,0,.4); }
    #prod img { width: 100%; height: 100%; object-fit: cover; }
    #prodTag { position: absolute; left: 448px; top: 540px; width: 184px; text-align: center; font-family: "Plex Arabic"; font-weight: 500; font-size: 26px; color: var(--cream); }
    #edit { position: absolute; left: 90px; top: 660px; width: 900px; padding: 26px 32px 30px; border-radius: 30px; color: var(--cream); }
    #edit .tx { font-size: 32px; line-height: 1.42; height: 270px; overflow: hidden; }
    #swap { white-space: nowrap; }
    #gen { position: absolute; right: 30px; bottom: -34px; font-family: "Plex Arabic"; font-weight: 500; font-size: 30px; color: var(--cream); background: var(--bordo);
      padding: 14px 34px 16px; border-radius: 40px; box-shadow: 0 14px 30px rgba(0,0,0,.3); }
    #tapGen { left: 790px; top: 380px; }

    /* liquid glass windows */
    #glass { position: absolute; left: 130px; top: 170px; width: 820px; height: 460px; opacity: 0; }
    #glass2 { position: absolute; left: 140px; top: 240px; width: 800px; height: 300px; opacity: 0; }
    .lbl { position: absolute; display: flex; align-items: center; justify-content: center;
      font-family: "Plex Arabic"; font-weight: 500; color: var(--green); opacity: 0; }
    #dots { left: 130px; top: 170px; width: 820px; height: 460px; font-size: 58px; letter-spacing: 0.12em; }
    .gimg { position: absolute; top: 256px; width: 200px; height: 252px; border-radius: 26px; overflow: hidden; opacity: 0; }
    .gimg img { position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; }
    #gA { left: 260px; } #gB { left: 620px; }
    #lAds { left: 260px; top: 512px; width: 200px; height: 44px; font-size: 32px; }
    #lPosters { left: 620px; top: 512px; width: 200px; height: 44px; font-size: 32px; }
    .ico { position: absolute; top: 358px; width: 64px; height: 64px; margin-left: -32px; transform-origin: 50% 50%; }
    #iLike { left: 390px; } #iSave { left: 540px; } #iShare { left: 690px; }
    #ptr { position: absolute; left: 0; top: 0; width: 24px; height: 24px; margin: -12px 0 0 -12px; border-radius: 50%; background: #fff;
      box-shadow: 0 0 8px rgba(255,255,255,.6), 0 2px 6px rgba(0,0,40,.25); opacity: 0; }

    /* link in bio + logo */
    .bio { position: absolute; left: 0; right: 0; top: 280px; display: flex; justify-content: center; }
    .bio .in { display: flex; align-items: center; gap: 18px; padding: 16px 30px 16px 18px; border-radius: 26px; background: var(--green);
      box-shadow: 0 20px 44px rgba(0,0,0,.28); }
    .bio .lg { height: 52px; }
    .bio .t { font-family: "Plex Arabic"; font-weight: 500; font-size: 36px; color: var(--cream); }
    .bio svg { width: 34px; height: 34px; }
    #site2 { position: absolute; left: 0; right: 0; top: 420px; display: flex; justify-content: center; }
    #site2 .in { font-family: "Plex Arabic"; font-weight: 500; font-size: 34px; color: var(--green); padding: 12px 28px; border-radius: 22px; }

    #browser, #folder, #prompt, .cv, #results, #hookBack .k1, #hookBack .k2, #hookFront .pill, #search, #home, #spill, #lens, #detail,
    #orig, #slot, #result, #prod, #prodTag, #edit, .ico, .bio .in, #site2 .in { opacity: 0; }
    .cap .strip { color: var(--green); }
    .kin { font-size: 80px; color: var(--green); }
  </style>
</head>
<body>
  <div id="root" data-composition-id="main" data-start="0" data-width="1080" data-height="1920" data-duration="44.5">

    <div class="bg"><div id="gridPar" class="layer" data-layout-allow-overflow><div id="grid" class="bg-grid"></div></div><div class="bg-vignette"></div></div>

    <div id="rigMove" class="layer"><div id="rig">
      <div id="cardShadow"></div>
      <div id="roomClip"><video id="room" src="graded.mov" muted playsinline data-start="0" data-duration="44.5" data-track-index="0"></video></div>
      <div id="cardEdge"></div>
      <div id="hookBack" data-layout-allow-overlap><div class="k1" data-layout-allow-overlap>أكبر مكتبة</div><div class="k2" data-layout-allow-overlap>PROMPTS</div></div>
      <div id="subjWrap"><video id="subj" src="subject.webm" muted playsinline data-start="0" data-duration="44.5" data-track-index="1"></video></div>
    </div></div>
    <div id="hookFront"><div class="pill">AI IMAGES</div></div>

    <div id="split" class="layer" data-layout-allow-overflow>
      <div id="kinHost" class="layer"></div>
      <div id="browser" class="browser glass">
        <div class="bar"><div class="dot"></div><div class="dot"></div><div class="dot"></div><div class="url">photogenerator.ai/explore</div></div>
        <div class="shot"><img src="assets/pg/gallery.jpg" alt="" /></div>
      </div>
      <div id="folderStage"><div id="folder">
        <div class="back"></div>
        <img id="cL" class="card" src="assets/pg/img03.jpg" alt="" />
        <img id="cC" class="card" src="assets/pg/img05.jpg" alt="" />
        <img id="cR" class="card" src="assets/pg/img07.jpg" alt="" />
        <div class="front">
          <svg viewBox="0 0 460 238"><path d="M18,0 H158 Q166,0 170,6 L198,37 Q202,43 210,43 H442 Q460,43 460,61 V220 Q460,238 442,238 H18 Q0,238 0,220 V18 Q0,0 18,0 Z" fill="none" stroke="rgba(255,255,255,.95)" stroke-width="3"/></svg>
          <div class="label"><div class="badge">PG</div><div class="word">PROMPTS</div></div>
          <div class="sub">+10 000</div>
        </div>
      </div></div>
      <div id="search" class="glass plain">
        <svg viewBox="0 0 24 24" fill="none" stroke="#0F3D3A" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/></svg>
        <span class="ph">Search</span>
      </div>
    </div>

    <div id="explain" class="layer" data-layout-allow-overflow>
      <div class="bg-deep"></div><div class="bg-deep-grid"></div>
      <div id="carousel">
        <div class="cv" id="cv1"><img src="assets/pg/man.jpg" alt="" /></div>
        <div class="cv" id="cv2"><img src="assets/pg/cat.jpg" alt="" /></div>
        <div class="cv" id="cv0"><img src="assets/pg/mask.jpg" alt="" /></div>
      </div>
      <div id="prompt" class="glass deep plain">
        <div class="phd"><span>Prompt</span><span class="cp">Copy</span></div>
        <div class="txw">
          <div class="tx" id="txA" dir="ltr"><span class="ln">Editorial beauty portrait of a young woman</span><span class="ln">holding a crystal-encrusted red rhinestone</span><span class="ln">masquerade mask, one striking blue eye…</span></div>
          <div class="tx" id="txB" dir="ltr"><span class="ln">A heartwarming studio portrait of a young</span><span class="ln">woman holding a cute orange tabby cat close</span><span class="ln">to her face, both sticking their tongues out…</span></div>
        </div>
      </div>
    </div>

    <div id="ex2" class="layer" data-layout-allow-overflow>
      <div class="bg-deep"></div><div class="bg-deep-grid"></div>
      <div id="wall">/*WALL*/</div>
      <div id="home" class="browser glass">
        <div class="bar"><div class="dot"></div><div class="dot"></div><div class="dot"></div><div class="url">photogenerator.ai</div></div>
        <div class="shot"><img src="assets/pg/site/home-top.jpg" alt="" /><div id="navHl"></div><div id="tapHome" class="tap"></div></div>
      </div>
    </div>

    <div id="ex3" class="layer" data-layout-allow-overflow>
      <div class="bg-deep"></div><div class="bg-deep-grid"></div>
      <div id="wheel">/*WHEEL*/</div>
      <div id="results" class="browser glass deep plain">
        <div class="bar"><div class="dot"></div><div class="dot"></div><div class="dot"></div><div class="url" style="color:var(--cream)">photogenerator.ai/explore?q=ad+for+hat</div></div>
        <div class="shot"><img src="assets/pg/site/results-crop.jpg" alt="" /></div>
      </div>
      <div id="pickRing"></div>
      <div id="spill" class="glass deep plain">
        <svg viewBox="0 0 24 24" fill="none" stroke="#F5DABF" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/></svg>
        <span class="q"><span id="qtext"></span><span class="caret"></span></span>
      </div>
      <div id="lens">
        <div class="in"><img src="assets/pg/hat/h01.jpg" alt="" /></div>
        <svg viewBox="0 0 330 330"><circle cx="130" cy="130" r="112" fill="none" stroke="#F5DABF" stroke-width="9"/><path d="M212 212 L300 300" stroke="#F5DABF" stroke-width="26" stroke-linecap="round"/><path d="M212 212 L300 300" stroke="#6C151E" stroke-width="12" stroke-linecap="round"/></svg>
      </div>
    </div>

    <div id="detail" class="glass">
      <div class="im"><img src="assets/pg/hat/h01.jpg" alt="" /><div id="tapDet" class="tap"></div></div>
      <div>
        <div class="phd"><span>Prompt</span><span class="cp">Use Prompt</span></div>
        <div class="tx" id="detTx" dir="ltr"><span class="ln">A cinematic magazine-style portrait of a</span><span class="ln">handsome man in side profile, wearing a</span><span class="ln">brown felt fedora hat and a cream-colored</span><span class="ln">suit jacket. Large serif text: "OLD MONEY."</span></div>
      </div>
    </div>

    <div id="ex4" class="layer" data-layout-allow-overflow>
      <div class="bg-deep"></div><div class="bg-deep-grid"></div>
      <div id="orig" class="pcard"><img src="assets/pg/hat/h01.jpg" alt="" /></div>
      <div id="slot" class="pcard"><span class="sp">• • •</span></div>
      <div id="result" class="pcard"><img src="assets/pg/oldmoney-chechia.jpg" alt="" /></div>
      <div id="prod"><img src="assets/pg/chechia-product.jpg" alt="" /></div>
      <div id="prodTag">product</div>
      <div id="edit" class="glass deep plain">
        <div class="phd"><span>Prompt</span><span class="cp">Edit</span></div>
        <div class="tx" dir="ltr">A cinematic magazine-style portrait of a handsome man in side profile, wearing <span id="swap" class="mk" style="--mk:0"><span id="swapT">a brown felt fedora hat</span></span> and a cream-colored suit jacket. He has short dark hair, light skin, and a well-groomed beard…</div>
        <div id="gen">Generate ✦</div>
      </div>
      <div id="tapGen" class="tap"></div>
    </div>

    <canvas id="glass"></canvas>
    <div id="dots" class="lbl">•••</div>
    <div id="gA" class="gimg"><img id="gA1" src="assets/pg/hat/h20.jpg" alt="" /><img id="gA2" src="assets/pg/hat/h07.jpg" alt="" /></div>
    <div id="gB" class="gimg"><img id="gB1" src="assets/pg/hat/h21.jpg" alt="" /><img id="gB2" src="assets/pg/hat/h23.jpg" alt="" /></div>
    <div id="lAds" class="lbl">ads</div>
    <div id="lPosters" class="lbl">posters</div>

    <canvas id="glass2"></canvas>
    <svg id="iLike" class="ico" viewBox="0 0 24 24" fill="none" stroke="#0F3D3A" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.6-7 10-7 10z"/></svg>
    <svg id="iSave" class="ico" viewBox="0 0 24 24" fill="none" stroke="#0F3D3A" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M6 3.5h12v17l-6-4.2-6 4.2z"/></svg>
    <svg id="iShare" class="ico" viewBox="0 0 24 24" fill="none" stroke="#0F3D3A" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 3L10 14"/><path d="M21 3l-7 18-4-7-7-4z"/></svg>
    <div id="ptr"></div>

    <div id="bio1" class="bio"><div class="in"><img class="lg" src="assets/pg/site/logo.svg" alt="" /><span class="t">link in bio</span>
      <svg viewBox="0 0 24 24" fill="none" stroke="#F5DABF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M6 13l6 6 6-6"/></svg></div></div>
    <div id="bio2" class="bio"><div class="in"><img class="lg" src="assets/pg/site/logo.svg" alt="" /><span class="t">link in bio</span>
      <svg viewBox="0 0 24 24" fill="none" stroke="#F5DABF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M6 13l6 6 6-6"/></svg></div></div>
    <div id="site2"><div class="in glass plain">photogenerator.ai</div></div>

    <div id="capHost" class="layer"></div>

<!--SFX-->
    <audio id="voice" src="audio/voice_studio.wav" data-start="0" data-duration="44.5" data-track-index="2" data-volume="1"></audio>
  </div>

  <script src="kit/conveyor.js"></script>
  <script src="kit/captions.js"></script>
  <script src="kit/liquid.js"></script>
  <script>
    const WORDS = /*WORDS*/;
    const MK = new Set([10, 17, 20, 28, 30, 36, 39, 42, 52, 58, 63, 81, 88, 92, 96, 102, 108, 110, 114]);
    const grp = (a, b, end) => ({ start: WORDS[a][0], end, words: WORDS.slice(a, b + 1).map((w, i) => ({ t: w[0], text: w[1], mk: MK.has(a + i) })) });
    const $ = (s) => document.querySelector(s);
    const tl = gsap.timeline({ paused: true });
    const rig = $("#rig"), rigMove = $("#rigMove"), gridPar = $("#gridPar");
    const END = 44.5;

    tl.set(rig, { transformOrigin: "50% 100%", scale: 1 }, 0);
    tl.set([rigMove, "#split"], { x: 0 }, 0);
    tl.set(["#explain", "#ex2", "#ex3", "#ex4"], { x: 1150 }, 0);
    Reel.drift(tl, $("#grid"), END);

    const toSplit = (t) => {        // rig into the pop-out state (used while it is off-screen)
      tl.set(rig, { scale: 0.8 }, t);
      tl.set("#roomClip", { clipPath: "inset(995px 0px 0px 0px round 56px)" }, t);
      tl.set(["#cardShadow", "#cardEdge", "#subjWrap"], { opacity: 1 }, t);
    };
    const toFull = (t) => {
      tl.set(["#subjWrap", "#cardShadow", "#cardEdge"], { opacity: 0 }, t);
      tl.set(rig, { scale: 1 }, t);
      tl.set("#roomClip", { clipPath: "inset(0px 0px 0px 0px round 0px)" }, t);
    };
    const tap = (sel, at) => tl.fromTo(sel, { scale: 0.4, opacity: 0.95 }, { scale: 1.9, opacity: 0, duration: 0.55, ease: "power2.out", immediateRender: false }, at);

    // ================= 0 - 14: approved demo =================
    // ---- TALK + hook (0 - 2.7)
    tl.set("#subjWrap", { opacity: 1 }, 0);
    tl.fromTo("#hookBack .k1", { x: 140, opacity: 0, filter: "blur(12px)" }, { x: 0, opacity: 1, filter: "blur(0px)", duration: 0.85, ease: "power3.out" }, 0.22);
    tl.fromTo("#hookBack .k2", { x: 180, opacity: 0, scale: 1.08, filter: "blur(14px)" }, { x: 0, opacity: 1, scale: 1, filter: "blur(0px)", duration: 0.95, ease: "power3.out" }, 1.15);
    tl.fromTo("#hookBack", { scale: 1 }, { scale: 1.04, duration: 2.6, ease: "none" }, 0);
    tl.fromTo("#hookFront .pill", { x: 120, opacity: 0, rotate: 0 }, { x: 0, opacity: 1, rotate: -3, duration: 0.75, ease: "back.out(1.6)" }, 1.88);
    Reel.exit(tl, ["#hookBack .k1", "#hookBack .k2", "#hookFront .pill"], 2.45, { dx: 160, duration: 0.55, stagger: 0.05 });

    // ---- FULL -> SPLIT pop-out (2.7 - 3.6), site, 3D folder (ref-04)
    tl.to(rig, { scale: 0.8, duration: 0.9, ease: "power2.inOut" }, 2.7);
    tl.to("#roomClip", { clipPath: "inset(995px 0px 0px 0px round 56px)", duration: 0.9, ease: "power2.inOut" }, 2.7);
    tl.to(["#cardShadow", "#cardEdge"], { opacity: 1, duration: 0.4 }, 3.2);
    Reel.enter(tl, "#browser", 3.05, { dx: 160 });
    Reel.exit(tl, "#browser", 4.1, { dx: 160, duration: 0.5 });
    Reel.enter(tl, "#folder", 4.3, { dx: 160 });
    tl.fromTo("#folder", { scale: 1, rotationY: -5, rotationZ: 0, y: 0 }, { scale: 1.14, rotationY: 14, rotationZ: 4, y: -6, duration: 1.45, ease: "sine.inOut" }, 4.6);
    tl.fromTo("#folder .front", { rotationX: 0 }, { rotationX: 20, duration: 1.45, ease: "sine.inOut" }, 4.6);
    tl.fromTo("#cR", { yPercent: 35, rotation: 8 }, { yPercent: -34, rotation: 22, duration: 1.3, ease: "sine.inOut" }, 4.9);
    tl.fromTo("#cC", { yPercent: 40, rotation: 0 }, { yPercent: -44, rotation: 2, duration: 1.3, ease: "sine.inOut" }, 5.0);
    tl.fromTo("#cL", { yPercent: 40, rotation: -5 }, { yPercent: -32, rotation: -20, duration: 1.2, ease: "sine.inOut" }, 5.1);

    // ---- SPLIT -> EXPLAIN 1 (7.25): cover-flow (ref-05) + real prompts
    Reel.conveyor(tl, [rigMove, "#split"], ["#explain"], 7.25, { grid: [gridPar, -120] });
    const SL = { C: { x: 0, z: 0, scale: 1, rotationY: 0 }, L: { x: -330, z: -200, scale: 0.78, rotationY: 14 }, R: { x: 330, z: -200, scale: 0.78, rotationY: -14 } };
    tl.set("#cv0", { opacity: 1, zIndex: 3 }, 7.25);
    tl.set(["#cv1", "#cv2"], { zIndex: 2 }, 7.25);
    tl.fromTo("#cv1", { x: 0, z: -260, scale: 0.7, rotationY: 0, opacity: 0 }, { ...SL.L, opacity: 1, duration: 0.65, ease: "expo.out" }, 7.75);
    tl.fromTo("#cv2", { x: 0, z: -260, scale: 0.7, rotationY: 0, opacity: 0 }, { ...SL.R, opacity: 1, duration: 0.65, ease: "expo.out" }, 7.75);
    Reel.enter(tl, "#prompt", 7.95, { dx: 140 });
    tl.fromTo("#txA .ln", { opacity: 0, x: 30, filter: "blur(6px)" }, { opacity: 1, x: 0, filter: "blur(0px)", duration: 0.45, ease: "power3.out", stagger: 0.14 }, 8.1);
    tl.set("#txB .ln", { opacity: 0 }, 0);
    const STEP = 8.72, SD = 0.55, SE = "power3.inOut";
    tl.to("#cv2", { ...SL.C, duration: SD, ease: SE }, STEP);
    tl.to("#cv0", { ...SL.L, duration: SD, ease: SE }, STEP);
    tl.to("#cv1", { ...SL.R, duration: SD, ease: SE }, STEP);
    tl.set("#cv2", { zIndex: 3 }, STEP + SD / 2);
    tl.set("#cv0", { zIndex: 2 }, STEP + SD / 2);
    tl.set("#cv1", { zIndex: 1 }, STEP);
    tl.to("#cv1", { opacity: 0.0, duration: 0.15 }, STEP + 0.1);
    tl.to("#cv1", { opacity: 1, duration: 0.2 }, STEP + SD - 0.2);
    tl.to("#txA .ln", { opacity: 0, x: -30, filter: "blur(6px)", duration: 0.25, ease: "power2.in", stagger: 0.05 }, STEP);
    tl.fromTo("#txB .ln", { opacity: 0, x: 30, filter: "blur(6px)" }, { opacity: 1, x: 0, filter: "blur(0px)", duration: 0.45, ease: "power3.out", stagger: 0.12, immediateRender: false }, STEP + 0.35);
    tl.fromTo("#carousel", { scale: 1 }, { scale: 1.04, duration: 2.3, ease: "none" }, 7.5);

    // ---- EXPLAIN 1 -> TALK (9.7)
    toFull(9.69);
    Reel.conveyor(tl, ["#explain"], [rigMove], 9.7, { grid: [gridPar, -240], lag: 0 });

    // ---- liquid glass: bubble splits into an "ads" card and a "posters" card with real images (10.5 - 13.6)
    const A = { x: 410, y: 230, w: 66, h: 66, r: 66, on: 0 }, B = { x: 410, y: 230, w: 66, h: 66, r: 66, on: 0 };
    const glass = Reel.liquid({ canvas: $("#glass"), size: [820, 460], t0: 10.5, t1: 14,
      frames: { pattern: (i) => `frames-ads/f${String(i).padStart(4, "0")}.jpg`, count: 105, fps: 30 }, shapes: [A, B], k: 80 });
    const blurIn = { opacity: 1, filter: "blur(0px)", duration: 0.35, ease: "power2.out" };
    const blurOut = { opacity: 0, filter: "blur(10px)", duration: 0.25, ease: "power2.in" };
    tl.set("#glass", { opacity: 1 }, 10.5);
    tl.set("#glass", { opacity: 0 }, 14);
    tl.fromTo([A, B], { on: 0 }, { on: 1, duration: 0.9, ease: "elastic.out(1, 0.5)" }, 10.55);
    tl.fromTo("#dots", { opacity: 0, filter: "blur(10px)" }, blurIn, 10.7);
    tl.to("#dots", blurOut, 10.95);
    tl.to(A, { x: 230, duration: 1.0, ease: "power3.inOut" }, 11.0);
    tl.to(B, { x: 590, duration: 1.0, ease: "power3.inOut" }, 11.0);
    tl.to(A, { w: 118, h: 160, r: 44, duration: 1.2, ease: "elastic.out(1, 0.45)" }, 11.15);
    tl.to(B, { w: 118, h: 160, r: 44, duration: 1.2, ease: "elastic.out(1, 0.45)" }, 11.25);
    tl.fromTo(["#gA", "#lAds"], { opacity: 0, scale: 0.85, filter: "blur(10px)" }, { ...blurIn, scale: 1 }, 11.55);
    tl.fromTo(["#gB", "#lPosters"], { opacity: 0, scale: 0.85, filter: "blur(10px)" }, { ...blurIn, scale: 1 }, 11.75);
    tl.set(["#gA2", "#gB2"], { opacity: 0 }, 0);
    tl.to("#gA2", { opacity: 1, duration: 0.35, ease: "power2.inOut" }, 12.1);
    tl.to("#gB2", { opacity: 1, duration: 0.35, ease: "power2.inOut" }, 12.2);
    tl.to(["#gA", "#gB", "#lAds", "#lPosters"], { ...blurOut, scale: 0.85 }, 12.55);
    tl.to([A, B], { x: 410, duration: 0.85, ease: "power3.inOut" }, 12.7);
    tl.to([A, B], { w: 66, h: 66, r: 66, duration: 0.9, ease: "elastic.out(1, 0.5)" }, 12.75);
    tl.to([A, B], { on: 0, duration: 0.4, ease: "back.in(2)" }, 13.5);

    // ================= 14 - 44.5 =================
    // ---- TALK+UI: link in bio (14.55)
    Reel.enter(tl, "#bio1 .in", 14.45, { dx: 140 });
    Reel.exit(tl, "#bio1 .in", 15.15, { dx: 140, duration: 0.45 });

    // ---- TALK -> EXPLAIN 2 (15.4): home page, tap "Prompt Gallery", then the card wall (ref-02)
    Reel.conveyor(tl, [rigMove], ["#ex2"], 15.4, { grid: [gridPar, -360] });
    Reel.enter(tl, "#home", 15.75, { dx: 160 });
    tl.fromTo("#navHl", { opacity: 0, scale: 0.9 }, { opacity: 1, scale: 1, duration: 0.3, ease: "power2.out" }, 16.2);
    tap("#tapHome", 16.3);
    Reel.exit(tl, "#home", 17.05, { dx: 200, duration: 0.55 });
    // wall: columns enter from the right as a wave, then flick up one pitch twice (L -> C -> R, 0.21 s apart)
    const PITCH = 660;
    tl.fromTo(["#colL", "#colC", "#colR"], { x: 900, opacity: 0 }, { x: 0, opacity: 1, duration: 0.85, ease: "power3.out", stagger: 0.08 }, 17.15);
    const flick = (at) => ["#colL", "#colC", "#colR"].forEach((c, i) => {
      const t = at + i * 0.21;
      tl.to(c, { y: `+=${10 + i * 6}`, duration: 0.28, ease: "sine.inOut" }, t - 0.28);
      tl.to(c, { y: `-=${PITCH + 10 + i * 6}`, duration: 1.15, ease: "power2.inOut" }, t);
      tl.fromTo(c, { filter: "blur(0px)" }, { filter: "blur(2.5px)", duration: 0.45, ease: "sine.inOut", yoyo: true, repeat: 1, immediateRender: false }, t + 0.12);
    });
    tl.set(["#colL", "#colC", "#colR"], { y: 0 }, 0);
    flick(18.25);
    flick(19.85);
    tl.fromTo("#wall", { y: 0 }, { y: -90, duration: 3.6, ease: "sine.out" }, 17.15);

    // ---- EXPLAIN 2 -> SPLIT (20.7): face comes back already popped out, search field on the stage
    toSplit(20.69);
    tl.set("#browser", { opacity: 0 }, 20.69);
    tl.set("#folder", { opacity: 0 }, 20.69);
    Reel.conveyor(tl, ["#ex2"], [rigMove, "#split"], 20.7, { grid: [gridPar, -480] });
    Reel.enter(tl, "#search", 21.6, { dx: 160 });
    tl.to("#search", { scale: 1.04, duration: 0.25, ease: "power2.out", yoyo: true, repeat: 1 }, 22.55);

    // ---- SPLIT -> EXPLAIN 3 (23.2): search pill types "ad for hat", card wheel spins (ref-03), magnifier picks OLD MONEY
    Reel.conveyor(tl, [rigMove, "#split"], ["#ex3"], 23.2, { grid: [gridPar, -600] });
    tl.fromTo("#wheel", { rotation: 44 }, { rotation: 0, duration: 1.3, ease: "power3.inOut" }, 23.45);
    tl.fromTo("#spill", { opacity: 0, scaleY: 0.05, scaleX: 0.6 }, { opacity: 1, scaleY: 1, scaleX: 1, duration: 0.3, ease: "power3.out" }, 23.8);
    // "كيما تراو" (25.14): the real results page for "ad for hat" replaces the wheel
    Reel.exit(tl, ["#wheel", "#spill"], 25.1, { dx: 200, duration: 0.55, stagger: 0.05 });
    Reel.enter(tl, "#results", 25.2, { dx: 200, duration: 0.8 });
    tl.fromTo("#results .shot img", { y: 0 }, { y: -40, duration: 2.6, ease: "sine.inOut" }, 25.3);
    tl.fromTo("#lens", { x: -200, y: -200, opacity: 0, rotation: -8 }, { x: 152, y: 300, opacity: 1, rotation: 0, duration: 0.6, ease: "power3.out" }, 26.85);
    tl.fromTo("#pickRing", { opacity: 0, scale: 1.12, y: -26 }, { opacity: 1, scale: 1.03, y: -26, duration: 0.35, ease: "power2.out" }, 27.35);
    tl.to("#lens", { x: 320, y: 180, rotation: 14, opacity: 0, duration: 0.4, ease: "power2.in" }, 27.6);

    // ---- EXPLAIN 3 -> TALK+UI (27.9): the chosen card's page, tap, its prompt
    toFull(27.89);
    Reel.conveyor(tl, ["#ex3"], [rigMove], 27.9, { grid: [gridPar, -720], lag: 0 });
    Reel.enter(tl, "#detail", 28.45, { dx: 160 });
    tap("#tapDet", 29.0);
    tl.set("#detTx .ln", { opacity: 0 }, 0);
    tl.fromTo("#detTx .ln", { opacity: 0, x: 24, filter: "blur(6px)" }, { opacity: 1, x: 0, filter: "blur(0px)", duration: 0.4, ease: "power3.out", stagger: 0.12, immediateRender: false }, 30.35);
    Reel.exit(tl, "#detail", 30.8, { dx: 160, duration: 0.45 });

    // ---- TALK -> EXPLAIN 4 (31.0): use it, swap the hat for the product, generate
    Reel.conveyor(tl, [rigMove], ["#ex4"], 31.0, { grid: [gridPar, -840] });
    Reel.enter(tl, ["#orig", "#slot"], 31.5, { dx: 140, stagger: 0.1 });
    Reel.enter(tl, "#edit", 31.6, { dx: 140 });
    tl.fromTo("#swap", { "--mk": 0 }, { "--mk": 1, duration: 0.3, ease: "power2.out" }, 33.35);
    Reel.enter(tl, ["#prod", "#prodTag"], 35.25, { dx: 140, stagger: 0.06 });
    tl.to("#gen", { scale: 0.94, duration: 0.12, ease: "power2.in", yoyo: true, repeat: 1 }, 36.85);
    tap("#tapGen", 36.9);
    tl.fromTo("#result", { opacity: 0, y: 60, filter: "blur(14px)", scale: 0.96 }, { opacity: 1, y: 0, filter: "blur(0px)", scale: 1, duration: 0.6, ease: "power3.out" }, 37.3);
    tl.to("#slot", { opacity: 0, duration: 0.3 }, 37.4);

    // ---- EXPLAIN 4 -> TALK (38.0): liquid glass dock (ref-01) with save / share
    toFull(37.99);
    Reel.conveyor(tl, ["#ex4"], [rigMove], 38.0, { grid: [gridPar, -960], lag: 0 });
    const D = { x: 400, y: 150, w: 0, h: 58, r: 58, on: 0 }, D2 = { x: 400, y: 150, w: 0, h: 0, r: 0, on: 0 };
    const glass2 = Reel.liquid({ canvas: $("#glass2"), size: [800, 300], t0: 38.3, t1: 41.3,
      frames: { pattern: (i) => `frames-dock/f${String(i).padStart(4, "0")}.jpg`, count: 90, fps: 30 }, shapes: [D, D2], k: 60 });
    const spring = (zeta = 0.63, wn = 14.5, dur = 1.0) => (p) => {
      if (p >= 1) return 1;
      const t = p * dur, wd = wn * Math.sqrt(1 - zeta * zeta);
      return 1 - Math.exp(-zeta * wn * t) * (Math.cos(wd * t) + (zeta * wn / wd) * Math.sin(wd * t));
    };
    tl.set("#glass2", { opacity: 1 }, 38.3);
    tl.set("#glass2", { opacity: 0 }, 41.3);
    tl.fromTo(D, { on: 0, w: 58 }, { on: 1, duration: 0.25, ease: "power2.out" }, 38.35);
    tl.to(D, { w: 255, duration: 1.0, ease: spring(0.63, 14.5, 1.0) }, 38.4);
    tl.fromTo(".ico", { scale: 0, opacity: 1 }, { scale: 1, opacity: 1, duration: 0.55, ease: "back.out(1.7)", stagger: 0.075 }, 38.6);
    tl.fromTo("#ptr", { x: 900, y: 600, opacity: 0 }, { x: 540, y: 430, opacity: 1, duration: 0.45, ease: "power3.out" }, 38.45);
    tl.to("#iSave", { scale: 1.18, duration: 0.25, ease: "power2.out" }, 38.75);
    tl.to("#ptr", { x: 525, duration: 0.25, ease: "none" }, 38.9);
    tl.to("#ptr", { x: 690, duration: 0.32, ease: "power2.inOut" }, 39.15);
    tl.to("#iSave", { scale: 1, duration: 0.2, ease: "power2.inOut" }, 39.18);
    tl.to("#iShare", { scale: 1.18, duration: 0.25, ease: "power2.out" }, 39.25);
    tl.to("#ptr", { x: 675, duration: 0.6, ease: "none" }, 39.5);
    tl.to(["#ptr", ".ico"], { scale: 0, opacity: 0, duration: 0.3, ease: "back.in(2)", stagger: 0.04 }, 40.55);
    tl.to(D, { w: 58, duration: 0.35, ease: "power2.in" }, 40.6);
    tl.to(D, { on: 0, duration: 0.3, ease: "back.in(2)" }, 40.85);

    // ---- end: link in bio + site (41.3 - 44.5)
    Reel.enter(tl, "#bio2 .in", 41.3, { dx: 140 });
    Reel.enter(tl, "#site2 .in", 43.5, { dx: 140 });

    // ---- typing (seek-safe: text derived from the timeline time)
    const Q = "ad for hat", OLD = "a brown felt fedora hat", NEW = "a traditional red Tunisian chechia";
    const lerpN = (t, a, b, n) => Math.max(0, Math.min(n, Math.floor(((t - a) / (b - a)) * n + 1e-6)));
    function typeAll(t) {
      $("#qtext").textContent = t < 24.26 ? "" : Q.slice(0, lerpN(t, 24.26, 25.0, Q.length));
      let s = OLD;
      if (t >= 33.75 && t < 34.35) s = OLD.slice(0, OLD.length - lerpN(t, 33.75, 34.3, OLD.length));
      else if (t >= 34.35) s = NEW.slice(0, lerpN(t, 34.35, 35.25, NEW.length));
      $("#swapT").textContent = s || "​";
    }

    // ---- captions
    Reel.captions(tl, $("#kinHost"), [grp(8, 11, 3.98), grp(12, 14, 5.26), grp(15, 18, 7.2), grp(53, 55, 21.76), grp(56, 58, 23.15)], { mode: "kin", top: 160 });
    Reel.captions(tl, $("#capHost"), [
      grp(19, 21, 8.58), grp(22, 25, 9.8), grp(26, 28, 11.14), grp(29, 30, 12.2), grp(31, 33, 13.1), grp(34, 36, 14.4), grp(37, 40, 15.38),
      grp(41, 42, 16.9), grp(43, 46, 17.95), grp(47, 50, 19.3), grp(51, 52, 20.65),
      grp(59, 60, 24.24), { start: WORDS[61][0], end: 25.1, words: [{ t: WORDS[61][0], text: "ad for hat", mk: true }] }, grp(64, 67, 26.2), grp(68, 69, 26.98), grp(70, 72, 27.92),
      grp(73, 75, 28.96), grp(76, 78, 29.78), grp(79, 81, 31.0), grp(82, 84, 32.06), grp(85, 86, 33.1), grp(87, 88, 34.4),
      grp(89, 91, 35.22), grp(92, 93, 36.2), grp(94, 97, 37.84), grp(98, 100, 38.46), grp(101, 102, 39.14), grp(103, 104, 40.2),
      grp(105, 106, 40.9), grp(107, 108, 41.7), grp(109, 111, 42.7), grp(112, 113, 43.5), grp(114, 115, 44.45)], { mode: "strip" });

    window.__hf = window.__hf || {}; window.__hf.buildReady = window.__hf.buildReady || {};
    window.__hf.buildReady["liquid"] = glass.ready;
    window.__hf.buildReady["liquid2"] = glass2.ready;
    tl.eventCallback("onUpdate", () => { const t = tl.time(); glass.render(t); glass2.render(t); typeAll(t); });
    typeAll(0);
    window.__timelines["main"] = tl;
  </script>
</body>
</html>
