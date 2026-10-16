import SbuKit
import SwiftUI

/// The quiet line shown when iOS's 64 notifications cover less than three days: open the app
/// at least every so many days, or later doses go unreminded.
struct OpenAppNotice: View {
    let days: Int

    var body: some View {
        Label {
            Text("Apri Sbu Meds almeno una volta ogni \(days) giorni per non perdere promemoria")
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.ink)
        } icon: {
            Image(systemName: "exclamationmark.triangle")
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.warning)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("openAppNotice")
    }
}

#Preview("Light") {
    OpenAppNoticePreview()
}

#Preview("Dark") {
    OpenAppNoticePreview()
        .preferredColorScheme(.dark)
}

private struct OpenAppNoticePreview: View {
    var body: some View {
        List {
            OpenAppNotice(days: 1)
                .listRowBackground(SbuTheme.surfaceRaised)
            OpenAppNotice(days: 2)
                .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
    }
}
