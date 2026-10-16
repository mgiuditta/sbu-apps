import SbuKit
import SwiftUI

/// The top of the dose card: form, how much, when it is due and where it stands.
struct DoseSheetHeader: View {
    let item: DoseItem

    var body: some View {
        HStack(alignment: .top, spacing: SbuTheme.space3) {
            Image(systemName: item.medicine.form.systemImage)
                .fontWeight(.medium)
                .imageScale(.large)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                Text(verbatim: item.medicine.detail(amount: item.amount))
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                Text(item.dueDate, format: .dateTime.weekday(.wide).day().month(.wide).hour().minute())
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
                if !item.medicine.personName.isEmpty {
                    Text(verbatim: item.medicine.personName)
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                DoseStateLabel(item: item)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, SbuTheme.space1)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    DoseRowsPreview()
}

#Preview("Dark") {
    DoseRowsPreview()
        .preferredColorScheme(.dark)
}
