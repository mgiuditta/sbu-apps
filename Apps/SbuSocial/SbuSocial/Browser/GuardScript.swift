import Foundation

/// The scripts a Platform's page runs: its CSS at the first byte, and the route guard.
///
/// Instagram and YouTube are single-page apps: moving inside them never reaches the navigation
/// delegate. The guard catches taps before the site does, refuses blocked paths in
/// `history.pushState`/`replaceState`, and checks the address every 400 ms as a safety net, so
/// it depends on paths, not on the page's layout. Posts with a hidden label are found by text.
nonisolated enum GuardScript {
    static func css(_ rules: PlatformRules) -> String {
        """
        (() => {
          const style = document.createElement('style');
          style.textContent = \(json(rules.css));
          (document.head || document.documentElement).appendChild(style);
        })();
        """
    }

    static func guardSource(_ rules: PlatformRules) -> String {
        let config = json(GuardConfig(rules: rules))
        return """
        (() => {
          const R = \(config);
          const matches = (path, pattern) =>
            pattern.endsWith('*') ? path.startsWith(pattern.slice(0, -1)) : path === pattern;
          const blocks = (path, current) =>
            R.blocked.some(b => matches(path, b)) ||
            R.single.some(s => current.startsWith(s) && path.startsWith(s) && path !== current);
          const redirect = (url) => {
            for (const [prefix, target] of Object.entries(R.rewrites)) {
              if (url.pathname.startsWith(prefix)) return target + url.pathname.slice(prefix.length);
            }
            return (url.search === '' && R.redirects[url.pathname]) || null;
          };

          for (const name of ['pushState', 'replaceState']) {
            const original = history[name];
            history[name] = function (state, title, url) {
              if (url != null) {
                const next = new URL(url, location.href);
                if (next.origin === location.origin) {
                  if (blocks(next.pathname, location.pathname)) return;
                  const target = redirect(next);
                  if (target) return original.call(this, state, title, target);
                }
              }
              return original.apply(this, arguments);
            };
          }

          document.addEventListener('click', (event) => {
            const link = event.target.closest && event.target.closest('a[href]');
            if (!link) return;
            const next = new URL(link.href, location.href);
            if (next.origin === location.origin && blocks(next.pathname, location.pathname)) {
              event.preventDefault();
              event.stopImmediatePropagation();
            }
          }, true);

          let last = location.pathname;
          setInterval(() => {
            const path = location.pathname;
            if (path !== last) {
              if (blocks(path, last)) { history.back(); return; }
              last = path;
            }
            const target = redirect(new URL(location.href));
            if (target) location.replace(target);
          }, 400);

          if (R.labels.length) {
            let queued = false;
            const scan = () => {
              queued = false;
              for (const element of document.querySelectorAll(R.container)) {
                if (element.style.display === 'none') continue;
                const text = element.innerText || '';
                if (R.labels.some(label => text.includes(label))) element.style.display = 'none';
              }
            };
            new MutationObserver(() => {
              if (!queued) { queued = true; requestAnimationFrame(scan); }
            }).observe(document.documentElement, { childList: true, subtree: true });
          }
        })();
        """
    }

    private struct GuardConfig: Encodable {
        let blocked: [String]
        let single: [String]
        let redirects: [String: String]
        let rewrites: [String: String]
        let labels: [String]
        let container: String

        init(rules: PlatformRules) {
            blocked = rules.blockedPaths
            single = rules.singlePaths
            redirects = rules.redirects
            rewrites = rules.rewrites
            labels = rules.hiddenLabels
            container = rules.labelContainer
        }
    }

    /// A value as a JavaScript literal: JSON, which also escapes quotes and line breaks in strings.
    private static func json(_ value: some Encodable) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        // ponytail: encoding plain strings, arrays and dictionaries cannot fail.
        return (try? encoder.encode(value)).flatMap { String(data: $0, encoding: .utf8) } ?? "null"
    }
}
