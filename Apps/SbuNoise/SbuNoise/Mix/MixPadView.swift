import SbuKit
import SwiftUI

/// The Mix Pad: the listener in the middle and the mix's sounds around it. Drag a sound to move
/// it left, right, in front or behind; nearer is louder. Tap it for its settings. The mix plays
/// while you change it.
struct MixPadView: View {
    let isNew: Bool
    let player: PlayerModel
    /// Closes the whole sheet: from the new mix flow `dismiss` would only go back to the sounds.
    let close: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var mix: Mix
    @State private var selection: MixLayer?
    @State private var isAddingSounds = false
    @State private var isNaming = false
    @State private var name = ""

    init(mix: Mix, isNew: Bool, player: PlayerModel, close: (() -> Void)? = nil) {
        self.isNew = isNew
        self.player = player
        self.close = close
        _mix = State(initialValue: mix)
    }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                let radius = (min(proxy.size.width, proxy.size.height) - 2 * SbuTheme.space8) / 2
                pad(radius: radius)
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
            if !isNew {
                VStack(spacing: SbuTheme.space3) {
                    SbuButton("Rinomina", kind: .secondary) { askName() }
                    SbuButton("Elimina mix", kind: .destructive) {
                        player.delete(mix)
                        leave()
                    }
                }
                .padding(SbuTheme.space4)
            }
        }
        .background(SbuTheme.paper)
        .navigationTitle(isNew ? Text("Mix Pad") : Text(verbatim: mix.name))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar { toolbar }
        .onAppear { player.preview(mix) }
        .onChange(of: mix) { player.preview(mix) }
        .sheet(item: $selection) { selected in
            if let index = mix.layers.firstIndex(where: { $0.id == selected.id }) {
                MixLayerSheet(soundName: soundName(mix.layers[index]), layer: $mix.layers[index]) {
                    mix.layers.remove(at: index)
                }
            }
        }
        .sheet(isPresented: $isAddingSounds) {
            NavigationStack {
                MixSoundPicker(sounds: player.sounds, limit: Mix.maxLayers - mix.layers.count, confirmTitle: "Aggiungi") { soundIDs in
                    for id in soundIDs { mix.add(id) }
                    isAddingSounds = false
                }
            }
        }
        .alert(isNew ? "Salva il mix" : "Rinomina il mix", isPresented: $isNaming) {
            TextField("Nome", text: $name)
            Button("Annulla", role: .cancel) {}
            Button("Salva") {
                let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { mix.name = trimmed }
                if isNew { finish() }
            }
        }
    }

    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Annulla") {
                player.endPreview()
                leave()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Fine") {
                if isNew { askName() } else { finish() }
            }
            .disabled(mix.layers.isEmpty)
        }
        ToolbarItem(placement: .primaryAction) {
            Button("Aggiungi suono", systemImage: "plus") { isAddingSounds = true }
                .disabled(mix.isFull)
        }
    }

    /// Drawn on the player's clock, so the sounds move where they are heard; still with Reduce Motion.
    @ViewBuilder private func pad(radius: CGFloat) -> some View {
        if !reduceMotion && mix.layers.contains(where: { $0.variance > 0 }) {
            TimelineView(.animation) { context in
                tokens(radius: radius, time: context.date.timeIntervalSince(player.wanderStart))
            }
        } else {
            tokens(radius: radius, time: 0)
        }
    }

    private func tokens(radius: CGFloat, time: TimeInterval) -> some View {
        ZStack {
            MixPadGrid(radius: radius)
            // The variance as a faint ink halo around each sound's place.
            ForEach(mix.layers.filter { $0.variance > 0 }) { layer in
                Circle()
                    .fill(SbuTheme.ink.opacity(0.12))
                    .frame(width: 2 * layer.variance * radius, height: 2 * layer.variance * radius)
                    .offset(x: layer.position.x * radius, y: layer.position.y * radius)
                    .accessibilityHidden(true)
            }
            ForEach(Array(mix.layers.enumerated()), id: \.element.id) { offset, layer in
                if let sound = player.sound(withID: layer.soundID) {
                    token(layer, sound: sound, at: MixSpace.position(of: layer, at: time, phase: Double(offset)), radius: radius)
                }
            }
        }
        .coordinateSpace(.named("pad"))
    }

    private func token(_ layer: MixLayer, sound: Sound, at point: MixPoint, radius: CGFloat) -> some View {
        MixToken(sound: sound, isSelected: selection?.id == layer.id)
            .offset(x: point.x * radius, y: point.y * radius)
            .gesture(drag(layer.id, radius: radius))
            .onTapGesture { selection = layer }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(sound.name))
            .accessibilityValue(Self.describe(layer.position))
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Apre volume, tono e varianza")
            .accessibilityAction { selection = layer }
            .accessibilityAction(named: "Sposta a sinistra") { move(layer.id, x: -0.25) }
            .accessibilityAction(named: "Sposta a destra") { move(layer.id, x: 0.25) }
            .accessibilityAction(named: "Sposta avanti") { move(layer.id, y: -0.25) }
            .accessibilityAction(named: "Sposta indietro") { move(layer.id, y: 0.25) }
    }

    private func drag(_ id: MixLayer.ID, radius: CGFloat) -> some Gesture {
        DragGesture(coordinateSpace: .named("pad")).onChanged { drag in
            guard let index = mix.layers.firstIndex(where: { $0.id == id }) else { return }
            // The pad space has its origin in the middle of the ZStack, which is the listener.
            let point = MixPoint(x: (drag.location.x - radius) / radius, y: (drag.location.y - radius) / radius)
            mix.layers[index].position = point.insidePad
        }
    }

    private func move(_ id: MixLayer.ID, x: Double = 0, y: Double = 0) {
        guard let index = mix.layers.firstIndex(where: { $0.id == id }) else { return }
        let position = mix.layers[index].position
        mix.layers[index].position = MixPoint(x: position.x + x, y: position.y + y).insidePad
    }

    private func soundName(_ layer: MixLayer) -> LocalizedStringResource {
        player.sound(withID: layer.soundID)?.name ?? "Suono"
    }

    private func askName() {
        name = mix.name
        isNaming = true
    }

    private func finish() {
        player.saveAndPlay(mix)
        leave()
    }

    private func leave() {
        if let close { close() } else { dismiss() }
    }

    /// Where a sound is, in words, for VoiceOver: "a sinistra, davanti".
    static func describe(_ point: MixPoint) -> Text {
        let side: Text = point.x < -0.2 ? Text("a sinistra") : point.x > 0.2 ? Text("a destra") : Text("al centro")
        let depth: Text? = point.y < -0.2 ? Text("davanti") : point.y > 0.2 ? Text("dietro") : nil
        guard let depth else { return side }
        return Text("\(side), \(depth)")
    }
}

#Preview("Light") {
    NavigationStack {
        MixPadView(mix: Mix(name: "Temporale", soundIDs: ["noise.pink", "noise.brown", "noise.white"]), isNew: true, player: PlayerModel())
    }
}

#Preview("Dark") {
    NavigationStack {
        MixPadView(mix: Mix(name: "Temporale", soundIDs: ["noise.pink", "noise.blue"]), isNew: false, player: PlayerModel())
    }
    .preferredColorScheme(.dark)
}
