import Observation
import UIKit
import WebKit

/// One web view per Account, kept alive while the app runs so switching back is instant and the
/// page keeps its place. Each Account has its own website data store, so its own login.
@Observable
final class WebViewPool: NSObject {
    @ObservationIgnored private var views: [UUID: WKWebView] = [:]
    @ObservationIgnored private var platforms: [ObjectIdentifier: Platform] = [:]
    @ObservationIgnored private var trackers: WKContentRuleList?
    @ObservationIgnored private var accountsByView: [ObjectIdentifier: UUID] = [:]
    /// How many ads and suggested posts each Account's page has hidden since the app opened.
    private(set) var hidden: [UUID: Int] = [:]

    /// The web view of an Account, made and loaded the first time.
    func webView(for account: Account) -> WKWebView {
        if let view = views[account.id] { return view }
        let view = WKWebView(frame: .zero, configuration: configuration(for: account))
        view.navigationDelegate = self
        view.uiDelegate = self
        view.allowsBackForwardNavigationGestures = true
        view.isInspectable = isDebug
        views[account.id] = view
        platforms[ObjectIdentifier(view)] = account.platform
        accountsByView[ObjectIdentifier(view)] = account.id
        view.load(URLRequest(url: account.platform.homeURL))
        return view
    }

    /// Sbu's own scripts that talk back to the app run here, where the page's scripts can't reach them.
    private static let world = WKContentWorld.world(name: "sbu")

    /// Stops every video and sound on the Account's page, as when the Limite di tempo closes it.
    func pauseMedia(of account: Account) {
        views[account.id]?.pauseAllMediaPlayback()
    }

    /// Compiles the tracker list once and adds it to every web view.
    func prepare() async {
        guard trackers == nil else { return }
        trackers = try? await WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: "trackers", encodedContentRuleList: TrackerRules.json)
        guard let trackers else { return }
        for view in views.values {
            view.configuration.userContentController.add(trackers)
        }
    }

    /// Drops the Account's web view, then deletes its cookies and data once WebKit lets go of the store.
    func remove(_ account: Account) {
        if let view = views.removeValue(forKey: account.id) {
            platforms[ObjectIdentifier(view)] = nil
            accountsByView[ObjectIdentifier(view)] = nil
            view.configuration.userContentController.removeScriptMessageHandler(forName: GuardScript.messageName, contentWorld: Self.world)
            view.removeFromSuperview()
        }
        Task {
            // WebKit refuses to delete a store still in use; the web view needs a moment to go.
            try? await Task.sleep(for: .seconds(1.5))
            try? await WKWebsiteDataStore.remove(forIdentifier: account.id)
        }
    }

    private func configuration(for account: Account) -> WKWebViewConfiguration {
        let rules = account.platform.rules
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore(forIdentifier: account.id)
        // The sites see Mobile Safari, not an in-app browser with fewer features.
        let version = UIDevice.current.systemVersion.split(separator: ".").prefix(2).joined(separator: ".")
        configuration.applicationNameForUserAgent = "Version/\(version) Mobile/15E148 Safari/604.1"
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        let content = configuration.userContentController
        content.addUserScript(WKUserScript(source: GuardScript.css(rules), injectionTime: .atDocumentStart, forMainFrameOnly: true))
        content.addUserScript(WKUserScript(source: GuardScript.guardSource(rules), injectionTime: .atDocumentStart, forMainFrameOnly: true))
        if let source = rules.scriptSource {
            content.addUserScript(WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        }
        if let trackers { content.add(trackers) }
        content.addUserScript(WKUserScript(source: GuardScript.counter(rules), injectionTime: .atDocumentEnd, forMainFrameOnly: true, in: Self.world))
        content.add(MessageRelay(pool: self), contentWorld: Self.world, name: GuardScript.messageName)
        return configuration
    }

    private var isDebug: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
}

/// Counts what the page hides. WebKit keeps its message handlers strongly, hence the weak hop to the pool.
private final class MessageRelay: NSObject, WKScriptMessageHandler {
    weak var pool: WebViewPool?

    init(pool: WebViewPool) {
        self.pool = pool
    }

    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        // One item per message, from the page itself: anything else is ignored.
        guard message.frameInfo.isMainFrame, (message.body as? Int) == 1, let webView = message.webView else { return }
        pool?.recordHidden(in: webView)
    }
}

extension WebViewPool {
    fileprivate func recordHidden(in webView: WKWebView) {
        guard let id = accountsByView[ObjectIdentifier(webView)] else { return }
        hidden[id, default: 0] += 1
    }
}

extension WebViewPool: WKNavigationDelegate {
    /// Full page loads: other sites open in Safari, blocked paths stay closed, redirects apply.
    /// Frames inside the page (the login's) load freely.
    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard action.targetFrame?.isMainFrame ?? true, let url = action.request.url,
              let platform = platforms[ObjectIdentifier(webView)] else { return .allow }
        guard url.scheme == "https" || url.scheme == "http" else { return .allow }
        let rules = platform.rules
        guard rules.allows(host: url.host()) else {
            await UIApplication.shared.open(url)
            return .cancel
        }
        if rules.blocks(path: url.path, from: webView.url?.path ?? "") { return .cancel }
        if let target = rules.redirect(url) {
            webView.load(URLRequest(url: target))
            return .cancel
        }
        return .allow
    }
}

extension WebViewPool: WKUIDelegate {
    /// Links meant for a new window open in the same web view, or in Safari when they leave the Platform.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for action: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = action.request.url, url.scheme == "https" || url.scheme == "http" {
            if let platform = platforms[ObjectIdentifier(webView)], platform.rules.allows(host: url.host()) {
                webView.load(action.request)
            } else {
                UIApplication.shared.open(url)
            }
        }
        return nil
    }
}
