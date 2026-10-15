import SbuKit
import SwiftUI

/// Reads the barcode or QR code already on an item or a box, with the camera or typed by hand.
///
/// The camera is asked for only here. Where the iPhone can't scan, or you said no to the camera,
/// you type the code printed under the bars instead.
struct ScanLabelSheet: View {
    let purpose: ScanPurpose
    let found: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var access = Access.checking
    @State private var isTyping = false
    @State private var typed = ""
    @FocusState private var isFieldFocused: Bool

    private enum Access {
        case checking, scanning, denied, unsupported
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(purpose.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annulla", action: close)
                    }
                }
        }
        .task { await checkAccess() }
    }

    @ViewBuilder
    private var content: some View {
        switch access {
        case .checking:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(SbuTheme.surface)
        case .scanning where !isTyping:
            LabelScannerView(found: finish)
                .ignoresSafeArea(edges: .bottom)
                .overlay(alignment: .bottom) {
                    VStack(spacing: SbuTheme.space3) {
                        Text("Inquadra il codice a barre o il QR sull'oggetto o sulla scatola.")
                            .font(SbuTheme.footnote)
                            .foregroundStyle(SbuTheme.ink)
                            .multilineTextAlignment(.center)
                        SbuButton("Scrivi il codice", kind: .secondary) { isTyping = true }
                    }
                    .padding(SbuTheme.space4)
                    .background(SbuTheme.surface, in: .rect(cornerRadius: SbuTheme.radiusLg))
                    .padding(SbuTheme.space4)
                }
        default:
            manualEntry
        }
    }

    private var manualEntry: some View {
        Form {
            if access == .denied {
                Section {
                    Label("Fotocamera non consentita", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(SbuTheme.warning)
                    Button("Apri Impostazioni", action: openSettings)
                } footer: {
                    Text("Per leggere le etichette con la fotocamera, consentila a Sbu Inventory nelle Impostazioni. Intanto puoi scrivere il codice.")
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
            Section {
                TextField("Codice dell'etichetta", text: $typed)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .focused($isFieldFocused)
                    .onSubmit(submitTyped)
                    .accessibilityIdentifier("labelCode")
            } footer: {
                Text(access == .unsupported
                     ? "Questo iPhone non legge i codici con la fotocamera: scrivi il numero stampato sotto il codice a barre."
                     : "Scrivi il numero stampato sotto il codice a barre.")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
            Section {
                SbuButton(purpose.confirmTitle, action: submitTyped)
                    .disabled(LabelLinker.normalized(typed) == nil)
                    .accessibilityIdentifier("labelConfirm")
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .onAppear { isFieldFocused = true }
    }

    private func checkAccess() async {
        guard access == .checking else { return }
        guard LabelScannerView.isSupported else {
            access = .unsupported
            return
        }
        access = await CameraAccess.request() && LabelScannerView.isAvailable ? .scanning : .denied
    }

    private func submitTyped() {
        guard let code = LabelLinker.normalized(typed) else { return }
        finish(code)
    }

    private func finish(_ code: String) {
        dismiss()
        found(code)
    }

    private func close() {
        dismiss()
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
    }
}

#Preview("Light") {
    ScanLabelSheet(purpose: .find) { _ in }
        .tint(SbuTheme.accentInventory)
}

#Preview("Dark") {
    ScanLabelSheet(purpose: .link) { _ in }
        .tint(SbuTheme.accentInventory)
        .preferredColorScheme(.dark)
}
