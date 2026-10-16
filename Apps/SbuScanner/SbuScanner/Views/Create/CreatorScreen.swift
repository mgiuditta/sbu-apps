import SbuKit
import SwiftData
import SwiftUI

/// The codes you made, newest first, and a menu to make another.
struct CreatorScreen: View {
    @Query(sort: \CreatedCode.created, order: .reverse) private var codes: [CreatedCode]
    @Environment(\.modelContext) private var modelContext
    @State private var newKind: CodeKind?

    var body: some View {
        List {
            ForEach(codes) { code in
                NavigationLink(value: ScannerRoute.created(code)) {
                    SbuListRow(
                        "\(code.title)",
                        subtitle: "\(Text(code.kind.title)) · \(code.created.formatted(date: .abbreviated, time: .omitted))",
                        systemImage: code.format == .qr ? "qrcode" : "barcode",
                        iconBackground: SbuTheme.surfaceSunken,
                        iconForeground: SbuTheme.inkMuted
                    )
                }
            }
            .onDelete { offsets in
                offsets.map { codes[$0] }.forEach(modelContext.delete)
                try? modelContext.save()
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .overlay {
            if codes.isEmpty {
                SbuEmpty(sentence: "Crea un QR per un link, una rete Wi-Fi o un contatto, o un codice a barre per un prodotto.") {
                    kindMenu { Text("Crea un codice") }
                }
                .padding(SbuTheme.space4)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .sbuPaper()
            }
        }
        .navigationTitle("Crea")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                kindMenu { Label("Nuovo codice", systemImage: "plus") }
                    .tint(SbuTheme.ink)
            }
        }
        .navigationDestination(item: $newKind) { kind in
            CreateFormScreen(kind: kind)
        }
    }

    private func kindMenu(@ViewBuilder label: () -> some View) -> some View {
        Menu {
            ForEach(CodeKind.allCases, id: \.self) { kind in
                Button {
                    newKind = kind
                } label: {
                    Label { Text(kind.title) } icon: { Image(systemName: kind.systemImage) }
                }
            }
        } label: {
            label()
        }
    }
}

#Preview("Light") {
    NavigationStack { CreatorScreen() }
        .modelContainer(.preview)
}

#Preview("Dark") {
    NavigationStack { CreatorScreen() }
        .modelContainer(for: CreatedCode.self, inMemory: true)
        .preferredColorScheme(.dark)
}
