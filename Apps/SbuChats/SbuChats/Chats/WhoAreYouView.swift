import SbuKit
import SwiftUI

/// "Chi sei?": which sender of the chat is you, so your numbers stand apart from the others'.
struct WhoAreYouView: View {
    let request: OwnerRequest
    let confirm: (String?) -> Void

    @State private var selection: Choice?

    private enum Choice: Hashable {
        case sender(String)
        case nobody
    }

    init(request: OwnerRequest, confirm: @escaping (String?) -> Void) {
        self.request = request
        self.confirm = confirm
        _selection = State(initialValue: request.current.map(Choice.sender))
    }

    var body: some View {
        List {
            Section {
                ForEach(request.senders, id: \.self) { sender in
                    ChoiceRow(title: Text(verbatim: sender), isSelected: selection == .sender(sender)) {
                        selection = .sender(sender)
                    }
                }
                ChoiceRow(title: Text("Nessuno di questi"), isSelected: selection == .nobody) {
                    selection = .nobody
                }
            } header: {
                Text("Chi sei in questa chat?")
            } footer: {
                Text("Serve a separare i tuoi numeri da quelli degli altri. Sbu Chats lo ricorda per le prossime chat.")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .navigationTitle(Text("Chi sei?"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Conferma", action: done)
                    .disabled(selection == nil)
            }
        }
    }

    private func done() {
        switch selection {
        case let .sender(sender): confirm(sender)
        case .nobody: confirm(nil)
        case nil: break
        }
    }
}

#Preview("Light") {
    NavigationStack {
        WhoAreYouView(request: OwnerRequest(chatID: 1, senders: ["Giulia", "Marco"])) { _ in }
    }
}

#Preview("Dark") {
    NavigationStack {
        WhoAreYouView(request: OwnerRequest(chatID: 1, senders: ["Giulia", "Marco"])) { _ in }
    }
    .preferredColorScheme(.dark)
}
