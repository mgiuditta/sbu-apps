import SbuKit
import SwiftUI

/// After a deletion: the space freed as the one figure, the total so far, and where the photos
/// went. No confetti, no "hours saved".
struct DeletionResultSheet: View {
    let result: DeletionResult

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SbuTheme.space4) {
                    SpaceStat(label: "Spazio liberato", bytes: result.bytes, context: "\(result.count) elementi eliminati")

                    Text("In totale con Sbu Clean: \(result.totalBytes.sizeText), \(result.totalCount) elementi.")
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)

                    RecentlyDeletedNote()
                }
                .padding(SbuTheme.space4)
            }
            .background(SbuTheme.paper)
            .navigationTitle("Eliminati")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview("Light") {
    DeletionResultSheet(result: DeletionResult(count: 37, bytes: 1_240_000_000, totalBytes: 3_100_000_000, totalCount: 120))
        .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    DeletionResultSheet(result: DeletionResult(count: 37, bytes: 1_240_000_000, totalBytes: 3_100_000_000, totalCount: 120))
        .environment(\.sbuAccent, .clean)
        .preferredColorScheme(.dark)
}
