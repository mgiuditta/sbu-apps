import SwiftUI

/// The accounts on a Platform: switch, add, reload the page, remove the one in use.
struct AccountMenu: View {
    let platform: Platform
    @Binding var removing: Account?

    @Environment(AccountStore.self) private var accounts
    @Environment(WebViewPool.self) private var pool

    var body: some View {
        Menu("Account", systemImage: "person.crop.circle") {
            let current = accounts.current(on: platform)
            Section {
                ForEach(accounts.accounts(on: platform)) { account in
                    Button {
                        accounts.select(account)
                    } label: {
                        if account == current {
                            Label("Account \(account.number)", systemImage: "checkmark")
                        } else {
                            Text("Account \(account.number)")
                        }
                    }
                }
            }
            Button("Aggiungi account", systemImage: "plus") {
                accounts.add(on: platform)
            }
            .disabled(!accounts.canAdd(on: platform))
            if let current {
                Button("Ricarica", systemImage: "arrow.clockwise") {
                    pool.webView(for: current).reload()
                }
                Button("Togli questo account", systemImage: "trash", role: .destructive) {
                    removing = current
                }
            }
        }
    }
}
