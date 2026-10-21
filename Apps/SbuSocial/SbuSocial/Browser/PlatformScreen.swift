import SbuKit
import SwiftUI

/// A Platform in its filtered browser, full screen without the tab bar, with the account menu at
/// the top and today's time above the page. Every second on screen counts toward the Limite di
/// tempo; reaching it closes the page with "Basta." until tomorrow.
struct PlatformScreen: View {
    let platform: Platform

    @Environment(AccountStore.self) private var accounts
    @Environment(WebViewPool.self) private var pool
    @Environment(UsageLog.self) private var usage
    @Environment(\.scenePhase) private var scenePhase
    @State private var removing: Account?
    @State private var isClosing = false

    var body: some View {
        Group {
            if usage.isOverLimit {
                LimitReachedView()
                    .sbuClosure($isClosing, word: "Basta")
            } else if let account = accounts.current(on: platform) {
                PlatformWebView(account: account, pool: pool)
                    .id(account.id)
                    .ignoresSafeArea(edges: .bottom)
                    .safeAreaInset(edge: .top, spacing: 0) {
                        UsageStrip(minutes: usage.minutes(on: .now, platform: platform), hidden: pool.hidden[account.id] ?? 0)
                    }
            }
        }
        .navigationTitle(Text(verbatim: platform.name))
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AccountMenu(platform: platform, removing: $removing)
            }
        }
        .onAppear {
            if accounts.current(on: platform) == nil { accounts.add(on: platform) }
        }
        .task(id: scenePhase) {
            await count()
        }
        .confirmationDialog(removalTitle, isPresented: isConfirmingRemoval, titleVisibility: .visible, presenting: removing) { account in
            Button("Togli", role: .destructive) { remove(account) }
        } message: { _ in
            Text("Esci da questo account e i suoi dati spariscono da questo iPhone.")
        }
    }

    /// One second at a time while the page is on screen and the app in front.
    private func count() async {
        guard scenePhase == .active else {
            usage.save()
            return
        }
        while !usage.isOverLimit {
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                usage.save()
                return
            }
            usage.add(1, on: platform)
        }
        if let account = accounts.current(on: platform) { pool.pauseMedia(of: account) }
        isClosing = true
    }

    private var removalTitle: Text {
        Text("Togliere l'account \(removing?.number ?? 0)?")
    }

    private var isConfirmingRemoval: Binding<Bool> {
        Binding { removing != nil } set: { if !$0 { removing = nil } }
    }

    private func remove(_ account: Account) {
        pool.remove(account)
        accounts.remove(account)
        if accounts.current(on: platform) == nil { accounts.add(on: platform) }
    }
}
