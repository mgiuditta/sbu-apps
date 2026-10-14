import SbuKit
import SwiftUI

/// What the code says, field by field; the text is selectable.
struct ContentDetails: View {
    let content: CodeContent
    let raw: String
    @State private var isShowingPassword = false

    var body: some View {
        Section {
            switch content {
            case .link:
                EmptyView()
            case let .text(text):
                Text(verbatim: text)
                    .textSelection(.enabled)
            case let .wifi(network):
                field("Rete", network.ssid)
                LabeledContent("Sicurezza", value: network.security == .open ? String(localized: "Nessuna") : network.security.rawValue)
                if !network.password.isEmpty {
                    LabeledContent("Password") {
                        Button {
                            isShowingPassword.toggle()
                        } label: {
                            Text(verbatim: isShowingPassword ? network.password : String(repeating: "•", count: 8))
                                .font(SbuTheme.body.monospaced())
                        }
                        .accessibilityLabel(isShowingPassword ? Text(verbatim: network.password) : Text("Nascosta"))
                        .accessibilityHint(isShowingPassword ? Text("Tocca per nasconderla.") : Text("Tocca per mostrarla."))
                    }
                }
                if network.isHidden { LabeledContent("Rete nascosta", value: String(localized: "Sì")) }
            case let .contact(card):
                field("Nome", card.name)
                field("Azienda", card.organization)
                ForEach(card.phones, id: \.self) { field("Telefono", $0) }
                ForEach(card.emails, id: \.self) { field("Email", $0) }
                field("Sito", card.website)
                field("Indirizzo", card.address)
            case let .email(message):
                field("A", message.address)
                field("Oggetto", message.subject)
                field("Testo", message.body)
            case let .phone(number):
                field("Numero", number)
            case let .textMessage(message):
                field("Numero", message.number)
                field("Testo", message.body)
            case let .location(point):
                field("Latitudine", point.latitude.formatted(.number.precision(.fractionLength(0...6))))
                field("Longitudine", point.longitude.formatted(.number.precision(.fractionLength(0...6))))
            case let .event(event):
                field("Titolo", event.title)
                LabeledContent("Inizio", value: event.start.formatted(date: .complete, time: event.isAllDay ? .omitted : .shortened))
                if let end = event.end {
                    LabeledContent("Fine", value: end.formatted(date: .complete, time: event.isAllDay ? .omitted : .shortened))
                }
                field("Luogo", event.location)
                field("Note", event.notes)
            case let .product(number):
                field("Numero", number)
            }
        }
    }

    /// A row with a value, left out when the value is empty; the value can be selected and copied.
    @ViewBuilder
    private func field(_ label: LocalizedStringKey, _ value: String) -> some View {
        if !value.isEmpty {
            LabeledContent(label) {
                Text(verbatim: value)
                    .textSelection(.enabled)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

#Preview("Light") {
    List {
        ContentDetails(content: CodeContent("WIFI:T:WPA;S:Casa;P:segreta;;", symbology: .qr), raw: "")
    }
}

#Preview("Dark") {
    List {
        ContentDetails(content: CodeContent("MECARD:N:Rossi,Anna;TEL:3331234567;;", symbology: .qr), raw: "")
    }
    .preferredColorScheme(.dark)
}
