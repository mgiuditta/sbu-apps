import SbuKit
import SwiftUI

/// A Platform in its filtered browser, full screen without the tab bar, with the account menu at the top.
struct PlatformScreen: View {
    let platform: Platform

    @Environment(AccountStore.self) private var accounts
    @Environment(WebViewPool.self) private var pool
    @State private var removing: Account?

    var body: some View {
        Group {
            if let account = accounts.current(on: platform) {
                PlatformWebView(account: account, pool: pool)
                    .id(account.id)
                    .ignoresSafeArea(edges: .bottom)
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
        .confirmationDialog(removalTitle, isPresented: isConfirmingRemoval, titleVisibility: .visible, presenting: removing) { account in
            Button("Togli", role: .destructive) { remove(account) }
        } message: { _ in
            Text("Esci da questo account e i suoi dati spariscono da questo iPhone.")
        }
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
