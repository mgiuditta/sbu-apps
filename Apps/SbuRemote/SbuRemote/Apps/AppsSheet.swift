import SbuKit
import SwiftUI

/// The apps on the TV, as the TV lists them (on Android TV, a short list of public links):
/// names as text with a generic symbol, never a logo. Tap to open, pin up to three in the remote's row.
struct AppsSheet: View {
    let session: RemoteSession
    let pins: PinnedAppsStore

    @Environment(\.dismiss) private var dismiss
    @State private var apps: [TVShortcut]?

    var body: some View {
        NavigationStack {
            List {
                if let apps {
                    Section {
                        ForEach(apps) { app in
                            AppRow(app: app, tvID: session.tv?.id, pins: pins, onOpen: open)
                        }
                        if apps.isEmpty {
                            Text("La TV non ha dato l'elenco delle app.")
                                .font(SbuTheme.body)
                                .foregroundStyle(SbuTheme.inkMuted)
                        }
                    } footer: {
                        Text("Fissa fino a tre app nella riga del telecomando.")
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .navigationTitle("App")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine", action: close)
                }
            }
            .task {
                await load()
            }
        }
    }

    private func load() async {
        var listed: [TVShortcut] = []
        await session.run { listed = try await $0.apps() }
        apps = listed.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private func open(_ app: TVShortcut) {
        Task { await session.run { try await $0.launch(app) } }
        dismiss()
    }

    private func close() {
        dismiss()
    }
}

/// One app: its name opens it on the TV, the pin keeps it in the remote's row.
private struct AppRow: View {
    let app: TVShortcut
    let tvID: UUID?
    let pins: PinnedAppsStore
    let onOpen: (TVShortcut) -> Void

    private var isPinned: Bool {
        tvID.map { pins.pins.isPinned(app, for: $0) } ?? false
    }

    private var canPin: Bool {
        isPinned || (tvID.map { pins.pins.canPin(for: $0) } ?? false)
    }

    var body: some View {
        HStack {
            Button {
                onOpen(app)
            } label: {
                Label {
                    Text(app.name)
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.ink)
                } icon: {
                    Image(systemName: "play.rectangle")
                        .fontWeight(.medium)
                }
            }
            Spacer()
            Button(isPinned ? "Togli dalla riga" : "Fissa nella riga", systemImage: isPinned ? "pin.fill" : "pin", action: togglePin)
                .labelStyle(.iconOnly)
                .fontWeight(.medium)
                .disabled(!canPin)
        }
        .buttonStyle(.borderless)
    }

    private func togglePin() {
        guard let tvID else { return }
        pins.toggle(app, for: tvID)
    }
}

#Preview("Light") {
    AppsSheet(session: .preview, pins: PinnedAppsStore(defaults: UserDefaults(suiteName: "preview") ?? .standard))
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    AppsSheet(session: .preview, pins: PinnedAppsStore(defaults: UserDefaults(suiteName: "preview") ?? .standard))
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
