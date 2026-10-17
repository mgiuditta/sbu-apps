import SbuKit
import SwiftUI

/// Pairing one TV: what will appear on it, the setting it needs, then the prompt or the code.
///
/// Once paired, the code zone gives way to the Closure, "Collegato", the one full stop of this
/// screen. The TV is saved at once; the sheet waits for the Closure to end before closing.
struct PairingView: View {
    @State private var model: PairingModel
    @State private var isClosing = false
    let onPaired: (SavedTV) -> Void

    init(candidate: TVCandidate, onPaired: @escaping (SavedTV) -> Void) {
        _model = State(initialValue: PairingModel(candidate: candidate))
        self.onPaired = onPaired
    }

    init(model: PairingModel, onPaired: @escaping (SavedTV) -> Void) {
        _model = State(initialValue: model)
        self.onPaired = onPaired
    }

    var body: some View {
        ScrollViewReader { proxy in
            list
                .onChange(of: model.phase) { _, phase in
                    guard phase == .paired, let tv = model.tv else { return }
                    isClosing = true
                    proxy.scrollTo(PairingPhaseSection.pairedID)
                    onPaired(tv)
                }
        }
        .onDisappear(perform: model.cancel)
    }

    private var list: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: SbuTheme.space1) {
                    Text(model.candidate.name)
                        .font(SbuTheme.headline)
                        .foregroundStyle(SbuTheme.ink)
                    Text(model.brand.displayName)
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .accessibilityElement(children: .combine)
            }
            .listRowBackground(SbuTheme.surfaceRaised)

            Section {
                Text(PairingGuide.onTheTV(model.brand))
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
            } header: {
                Text("Sulla TV")
            } footer: {
                Text(PairingGuide.setting(model.brand))
            }
            .listRowBackground(SbuTheme.surfaceRaised)

            PairingPhaseSection(model: model, isClosing: $isClosing)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .navigationTitle("Collega la TV")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// The part of the pairing screen that changes with each step.
private struct PairingPhaseSection: View {
    static let pairedID = "paired"

    let model: PairingModel
    @Binding var isClosing: Bool

    @State private var code = ""
    @State private var preSharedKey = ""
    @FocusState private var isCodeFocused: Bool

    var body: some View {
        switch model.phase {
        case .ready:
            Section {
                SbuButton("Collega", action: start)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
        case .waiting:
            Section {
                HStack(spacing: SbuTheme.space3) {
                    ProgressView()
                    Text("Guarda la TV")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .accessibilityElement(children: .combine)
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        case .code(let length, let isHexadecimal):
            codeSection(length: length, isHexadecimal: isHexadecimal)
            if model.brand == .sony {
                preSharedKeySection
            }
        case .confirmPlain:
            Section {
                Label {
                    Text("Questa TV parla senza cifratura sulla rete di casa: chi usa la stessa Wi-Fi può leggere i comandi che le mandi. Succede con i modelli meno recenti.")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.ink)
                } icon: {
                    Image(systemName: "lock.open")
                        .fontWeight(.medium)
                        .foregroundStyle(SbuTheme.warning)
                }
                Button("Collega senza cifratura", action: startPlain)
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        case .failed(let error):
            Section {
                Label {
                    Text(error.message)
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.ink)
                } icon: {
                    Image(systemName: "exclamationmark.triangle")
                        .fontWeight(.medium)
                        .foregroundStyle(SbuTheme.warning)
                }
                Button("Riprova", action: start)
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        case .paired:
            Section {
                HStack(spacing: SbuTheme.space2) {
                    SbuRowMark(filled: true)
                    Text("Collegata")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.ink)
                }
                .padding(SbuTheme.space4)
                .frame(maxWidth: .infinity, minHeight: SbuTheme.gridCell * 5, alignment: .leading)
                .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusCard))
                .accessibilityElement(children: .combine)
                .sbuClosure($isClosing, word: "Collegato")
                .id(Self.pairedID)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
    }

    private func codeSection(length: Int, isHexadecimal: Bool) -> some View {
        let valid = PairingCode.normalized(code, length: length, isHexadecimal: isHexadecimal)
        return Section {
            TextField(isHexadecimal ? "Codice di 6 caratteri" : "PIN di 4 cifre", text: $code)
                .font(SbuTheme.body.monospaced())
                .keyboardType(isHexadecimal ? .asciiCapable : .numberPad)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .focused($isCodeFocused)
                .onAppear { isCodeFocused = true }
            Button("Conferma") {
                guard let valid else { return }
                Task { await model.submit(code: valid) }
            }
            .disabled(valid == nil)
        } header: {
            Text("Codice sulla TV")
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }

    private var preSharedKeySection: some View {
        Section {
            SecureField("Chiave precondivisa", text: $preSharedKey)
            Button("Usa la chiave") {
                Task { await model.submit(preSharedKey: preSharedKey) }
            }
            .disabled(preSharedKey.trimmingCharacters(in: .whitespaces).isEmpty)
        } footer: {
            Text("Se hai scelto una chiave in Controllo IP, puoi usarla al posto del PIN.")
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }

    private func start() {
        Task { await model.start() }
    }

    private func startPlain() {
        Task { await model.start(allowingPlain: true) }
    }
}

#Preview("Light") {
    NavigationStack {
        PairingView(candidate: TVCandidate(host: "192.168.1.20", brand: .samsung)) { _ in }
    }
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NavigationStack {
        PairingView(candidate: TVCandidate(host: "192.168.1.40", brand: .sony)) { _ in }
    }
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
