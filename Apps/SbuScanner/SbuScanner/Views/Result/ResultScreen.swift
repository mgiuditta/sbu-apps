import SbuKit
import SwiftData
import SwiftUI

/// What a code says and what to do with it: where a link goes before it opens, the fields of a
/// contact or a network, and the action that fits at the bottom.
struct ResultScreen: View {
    let record: ScanRecord
    @Environment(\.openURL) private var openURL
    @State private var sheet: ResultSheet?
    @State private var risky: URL?
    @State private var wifiOutcome: WiFiJoiner.Outcome?
    @State private var copies = 0

    var body: some View {
        let content = record.content
        let primary = ResultAction.primary(for: content, raw: record.raw)
        List {
            Section {
                ResultHeader(record: record, content: content)
            }
            if case let .link(url) = content, let check = LinkCheck(url) {
                LinkCheckSection(url: url, check: check)
            }
            ContentDetails(content: content, raw: record.raw)
            Section {
                ForEach(ResultAction.secondary(for: content, raw: record.raw), id: \.systemImage) { action in
                    Button(action.title(for: content), systemImage: action.systemImage) { perform(action) }
                }
                ShareLink(item: record.raw) {
                    Label("Condividi", systemImage: "square.and.arrow.up")
                }
            }
            if record.modelContext != nil {
                ResultHistorySection(record: record)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle(Text(content.kind.title))
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            SbuButton(primary.title(for: content)) { perform(primary) }
                .padding(.horizontal, SbuTheme.space4)
                .padding(.vertical, SbuTheme.space2)
                .background(SbuTheme.surface)
        }
        .sensoryFeedback(.success, trigger: copies)
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case let .contact(card): ContactEditor(card: card).ignoresSafeArea()
            case let .event(event): EventEditor(event: event).ignoresSafeArea()
            }
        }
        .alert("Aprire comunque il link?", isPresented: isConfirmingRisky, presenting: risky) { url in
            Button("Apri") { openURL(url) }
            Button("Annulla", role: .cancel) {}
        } message: { _ in
            Text("Il link ha qualcosa di strano: controlla il sito prima di scrivere password o dati.")
        }
        .alert(wifiTitle, isPresented: isShowingWiFiOutcome) {
            Button("OK", role: .cancel) {}
        } message: {
            if wifiOutcome == .failed {
                Text("Controlla di essere vicino alla rete. Puoi copiare la password e inserirla in Impostazioni > Wi-Fi.")
            }
        }
    }

    private func perform(_ action: ResultAction) {
        switch action {
        case let .open(url):
            if case let .link(link) = record.content, let check = LinkCheck(link), !check.warnings.isEmpty {
                risky = url
            } else {
                openURL(url)
            }
        case let .joinWiFi(network):
            Task { wifiOutcome = await WiFiJoiner.join(network) }
        case let .addContact(card):
            sheet = .contact(card)
        case let .addEvent(event):
            sheet = .event(event)
        case let .copy(text), let .copyPassword(text):
            UIPasteboard.general.string = text
            copies += 1
            AccessibilityNotification.Announcement(String(localized: "Copiato")).post()
        case let .searchWeb(query):
            if let url = ResultAction.searchURL(query) { openURL(url) }
        }
    }

    private var isConfirmingRisky: Binding<Bool> {
        Binding { risky != nil } set: { if !$0 { risky = nil } }
    }

    private var isShowingWiFiOutcome: Binding<Bool> {
        Binding { wifiOutcome == .joined || wifiOutcome == .failed } set: { if !$0 { wifiOutcome = nil } }
    }

    private var wifiTitle: LocalizedStringKey {
        wifiOutcome == .failed ? "Connessione non riuscita" : "Connesso"
    }
}

#Preview("Light") {
    NavigationStack {
        ResultScreen(record: ScanRecord(raw: "http://bit.ly/sbu", symbology: .qr))
    }
}

#Preview("Dark") {
    NavigationStack {
        ResultScreen(record: ScanRecord(raw: "WIFI:T:WPA;S:Casa;P:segreta;;", symbology: .qr))
    }
    .preferredColorScheme(.dark)
}
