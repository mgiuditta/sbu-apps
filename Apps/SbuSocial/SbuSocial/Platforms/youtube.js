// YouTube in Sbu Social: no ads, and the video keeps playing when you leave the app.
(() => {
  // Ads come inside the player's data: take them out before the player reads it.
  const AD_KEYS = ['adPlacements', 'adSlots', 'playerAds', 'adBreakHeartbeatParams'];
  const strip = (value) => {
    if (value && typeof value === 'object') {
      if (AD_KEYS.some(key => key in value)) {
        // Counted by Sbu's own script, which the page can't reach.
        const root = document.documentElement;
        if (root) root.dataset.sbuAds = String(Number(root.dataset.sbuAds || 0) + 1);
      }
      for (const key of AD_KEYS) delete value[key];
      if (value.playerResponse) strip(value.playerResponse);
    }
    return value;
  };
  const parse = JSON.parse;
  JSON.parse = function () { return strip(parse.apply(this, arguments)); };
  const json = Response.prototype.json;
  Response.prototype.json = async function () { return strip(await json.call(this)); };
  let initial;
  Object.defineProperty(window, 'ytInitialPlayerResponse', {
    configurable: true,
    get: () => initial,
    set: (value) => { initial = strip(value); },
  });

  // Ads stitched into the video: skip them when YouTube allows, otherwise mute them and run them to the end.
  let muted = false;
  setInterval(() => {
    const video = document.querySelector('video');
    if (!video) return;
    if (!document.querySelector('.ad-showing')) {
      if (muted) { video.muted = false; video.playbackRate = 1; muted = false; }
      return;
    }
    const skip = document.querySelector('.ytp-ad-skip-button, .ytp-ad-skip-button-modern, .ytp-skip-ad-button');
    if (skip) { skip.click(); return; }
    video.muted = true;
    video.playbackRate = 16;
    muted = true;
    if (isFinite(video.duration)) video.currentTime = video.duration;
  }, 300);

  // The home feed is the algorithm's: on the home page it stays hidden, search and the menu stay.
  setInterval(() => {
    document.documentElement.classList.toggle('sbu-home', location.pathname === '/');
  }, 200);

  // In the background the page still believes it is on screen, so YouTube doesn't pause the video.
  Object.defineProperty(Document.prototype, 'visibilityState', { configurable: true, get: () => 'visible' });
  Object.defineProperty(Document.prototype, 'hidden', { configurable: true, get: () => false });
  document.addEventListener('visibilitychange', (event) => event.stopImmediatePropagation(), true);
  document.addEventListener('webkitpresentationmodechanged', (event) => event.stopImmediatePropagation(), true);
})();
