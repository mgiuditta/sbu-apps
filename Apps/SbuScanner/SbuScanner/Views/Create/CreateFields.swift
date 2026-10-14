import SwiftUI

/// The fields of the kind being made.
struct CreateFields: View {
    @Binding var draft: CodeDraft

    var body: some View {
        Section {
            switch draft.kind {
            case .text:
                TextField("Testo", text: $draft.text, axis: .vertical)
                    .lineLimit(3...8)
            case .link:
                TextField("Indirizzo, come sbu.dev", text: $draft.link)
                    .keyboardType(.URL)
                    .textContentType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            case .wifi:
                TextField("Nome della rete", text: $draft.wifi.ssid)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Picker("Sicurezza", selection: $draft.wifi.security) {
                    Text(verbatim: "WPA/WPA2/WPA3").tag(WiFiNetwork.Security.wpa)
                    Text(verbatim: "WEP").tag(WiFiNetwork.Security.wep)
                    Text("Nessuna").tag(WiFiNetwork.Security.open)
                }
                if draft.wifi.security != .open {
                    TextField("Password", text: $draft.wifi.password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                Toggle("Rete nascosta", isOn: $draft.wifi.isHidden)
            case .contact:
                TextField("Nome e cognome", text: $draft.contact.name)
                    .textContentType(.name)
                TextField("Azienda", text: $draft.contact.organization)
                    .textContentType(.organizationName)
                TextField("Telefono", text: $draft.contactPhone)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                TextField("Email", text: $draft.contactEmail)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                TextField("Sito", text: $draft.contact.website)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                TextField("Indirizzo", text: $draft.contact.address, axis: .vertical)
            case .email:
                TextField("A", text: $draft.email.address)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                TextField("Oggetto", text: $draft.email.subject)
                TextField("Testo", text: $draft.email.body, axis: .vertical)
                    .lineLimit(3...8)
            case .phone:
                TextField("Numero", text: $draft.phone)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
            case .textMessage:
                TextField("Numero", text: $draft.message.number)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                TextField("Testo", text: $draft.message.body, axis: .vertical)
                    .lineLimit(2...6)
            case .location:
                TextField("Latitudine, come 45,4642", text: $draft.latitude)
                    .keyboardType(.numbersAndPunctuation)
                TextField("Longitudine, come 9,19", text: $draft.longitude)
                    .keyboardType(.numbersAndPunctuation)
            case .event:
                TextField("Titolo", text: $draft.event.title)
                Toggle("Tutto il giorno", isOn: $draft.event.isAllDay)
                DatePicker("Inizio", selection: $draft.event.start, displayedComponents: draft.event.isAllDay ? .date : [.date, .hourAndMinute])
                DatePicker("Fine", selection: endBinding, in: draft.event.start..., displayedComponents: draft.event.isAllDay ? .date : [.date, .hourAndMinute])
                TextField("Luogo", text: $draft.event.location)
                TextField("Note", text: $draft.event.notes, axis: .vertical)
            case .product:
                TextField("Numero del prodotto", text: $draft.productNumber)
                    .keyboardType(.numberPad)
            }
        } footer: {
            if draft.kind == .product, draft.format == .ean13 {
                Text("EAN-13: 12 cifre, l'ultima la calcola Sbu Scanner, o 13 con quella giusta.")
            } else if draft.kind == .location {
                Text("Le coordinate le trovi in Mappe: tocca e tieni premuto un punto, poi scorri in basso.")
            }
        }
    }

    private var endBinding: Binding<Date> {
        Binding { draft.event.end ?? draft.event.start } set: { draft.event.end = $0 }
    }
}

#Preview("Light") {
    @Previewable @State var draft = CodeDraft(kind: .wifi)
    Form { CreateFields(draft: $draft) }
}

#Preview("Dark") {
    @Previewable @State var draft = CodeDraft(kind: .event)
    Form { CreateFields(draft: $draft) }
        .preferredColorScheme(.dark)
}
