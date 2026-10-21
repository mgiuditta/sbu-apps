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
        view.load(URLRequest(url: account.platform.homeURL))
        return view
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
        if let trackers { content.add(trackers) }
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
        if let url = action.request.url {
            if let platform = platforms[ObjectIdentifier(webView)], platform.rules.allows(host: url.host()) {
                webView.load(action.request)
            } else {
                UIApplication.shared.open(url)
            }
        }
        return nil
    }
}
