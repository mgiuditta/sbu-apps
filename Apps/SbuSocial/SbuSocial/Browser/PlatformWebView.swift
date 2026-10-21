import SwiftUI
import WebKit

/// Shows an Account's web view from the pool: the same page every time you come back.
struct PlatformWebView: UIViewRepresentable {
    let account: Account
    let pool: WebViewPool

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let webView = pool.webView(for: account)
        webView.removeFromSuperview()
        webView.frame = container.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(webView)
        return container
    }

    // A new Account gets a new container: the caller keys this view by the Account's id.
    func updateUIView(_ container: UIView, context: Context) {}
}
