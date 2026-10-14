import SbuKit
import SwiftData
import SwiftUI

/// Makes one code: the fields, the code drawn as you type, then share it or keep it in the list.
struct CreateFormScreen: View {
    @State private var draft: CodeDraft
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    init(kind: CodeKind) {
        _draft = State(initialValue: CodeDraft(kind: kind))
    }

    var body: some View {
        let payload = draft.payload
        let graphic = payload.flatMap { CodeGraphic($0, format: draft.format) }
        Form {
            CreateFields(draft: $draft)
            if draft.formats.count > 1 {
                Section {
                    Picker("Formato", selection: $draft.format) {
                        ForEach(draft.formats, id: \.self) { Text($0.title).tag($0) }
                    }
                }
            }
            Section {
                TextField(text: $draft.title, prompt: Text(verbatim: draft.suggestedTitle.isEmpty ? String(localized: "Nome nell'elenco") : draft.suggestedTitle)) {
                    Text("Nome nell'elenco")
                }
            }
            Section {
                if let graphic {
                    CodeImage(graphic: graphic, label: CodeContent(payload ?? "", symbology: draft.format.symbology).summary)
                        .frame(maxWidth: graphic.isBarcode ? .infinity : 240)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(SbuTheme.surfaceRaised)
                    CodeShareButtons(graphic: graphic, name: name)
                } else {
                    Text("Il codice compare qui quando i campi sono completi.")
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle(Text(draft.kind.title))
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            SbuButton("Salva nell'elenco", action: save)
                .disabled(payload == nil)
                .padding(.horizontal, SbuTheme.space4)
                .padding(.vertical, SbuTheme.space2)
                .background(SbuTheme.surface)
        }
    }

    private var name: String {
        let typed = draft.title.trimmingCharacters(in: .whitespaces)
        return typed.isEmpty ? draft.suggestedTitle : typed
    }

    private func save() {
        guard let payload = draft.payload else { return }
        modelContext.insert(CreatedCode(title: name, kind: draft.kind, format: draft.format, payload: payload))
        try? modelContext.save()
        dismiss()
    }
}

#Preview("Light") {
    NavigationStack { CreateFormScreen(kind: .link) }
        .modelContainer(.preview)
}

#Preview("Dark") {
    NavigationStack { CreateFormScreen(kind: .product) }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
