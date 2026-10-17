import SbuKit
import SwiftUI

/// Medicines taken as needed: no time, a "Prendi" that writes the dose into today's history.
struct AsNeededSection: View {
    let medicines: [Medicine]
    let take: (Medicine) -> Void

    var body: some View {
        Section("Al bisogno") {
            ForEach(medicines) { medicine in
                HStack(spacing: SbuTheme.space3) {
                    Image(systemName: medicine.form.systemImage)
                        .fontWeight(.medium)
                        .imageScale(.medium)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .frame(width: SbuTheme.space6)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: SbuTheme.space1) {
                        Text(medicine.name)
                            .font(SbuTheme.headline)
                            .foregroundStyle(SbuTheme.ink)
                        Text(verbatim: medicine.snapshot.detail(amount: medicine.asNeededAmount))
                            .font(SbuTheme.subheadline)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                    Spacer(minLength: SbuTheme.space2)
                    Button("Prendi") { take(medicine) }
                        .buttonStyle(.bordered)
                        .accessibilityLabel(Text("Prendi \(medicine.name)"))
                        .accessibilityIdentifier("takeAsNeeded")
                }
                .padding(.vertical, SbuTheme.space1)
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
    }
}

#Preview("Light") {
    AsNeededSectionPreview()
}

#Preview("Dark") {
    AsNeededSectionPreview()
        .preferredColorScheme(.dark)
}

private struct AsNeededSectionPreview: View {
    var body: some View {
        List {
            AsNeededSection(medicines: [Medicine(name: "Antistaminico", form: .tablet, schedule: Schedule(frequency: .asNeeded, start: Day(.now, calendar: .current)))]) { _ in }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .environment(\.sbuAccent, .meds)
    }
}
