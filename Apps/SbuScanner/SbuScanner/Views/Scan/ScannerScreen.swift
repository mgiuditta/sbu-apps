import PhotosUI
import SbuKit
import SwiftData
import SwiftUI

/// The tool screen: the camera reads any code by itself and opens what it says.
///
/// Scanner has no figure, so no full stop while it scans: the camera is the instrument. A code
/// saved to the history closes with "Salvato" over the camera, then its result opens.
struct ScannerScreen: View {
    @State private var model = ScannerModel()
    @State private var opened: ScanRecord?
    /// The code just read and saved, waiting for the Closure to end before it opens.
    @State private var saved: ScanRecord?
    @State private var isClosing = false
    @State private var unsavedReads = 0
    @State private var isOnScreen = false
    @State private var isChoosingPhoto = false
    @State private var photoItem: PhotosPickerItem?
    @State private var photoReadings: [CodeReading] = []
    @State private var isShowingNoCodeAlert = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(ScannerSettings.sound) private var playsSound = true
    @AppStorage(ScannerSettings.vibration) private var vibrates = true
    @AppStorage(ScannerSettings.saveHistory) private var savesHistory = true

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                SbuScreenTitle("Scanner", cartiglio: cartiglio)
                Text("QR e codici a barre, anche da una foto.")
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            // Never squeezed by the camera, which takes all the height left: the title keeps its lines.
            .fixedSize(horizontal: false, vertical: true)
            CameraFrame(model: model)
                .sbuClosure($isClosing, word: "Salvato")
            HStack(spacing: SbuTheme.space2) {
                ScanPills(model: model) { isChoosingPhoto = true }
            }
        }
        .padding(.horizontal, SbuTheme.space4)
        .padding(.top, SbuTheme.space4)
        .padding(.bottom, SbuTheme.space8)
        // The camera shows the person's surroundings: plain paper, no grid under it.
        .sbuPaper(grid: false)
        .sensoryFeedback(SbuHaptic.dot.feedback, trigger: unsavedReads) { _, _ in vibrates }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(value: ScannerRoute.history) {
                    Label("Cronologia", systemImage: "clock.arrow.circlepath")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: ScannerRoute.creator) {
                    Label("Crea", systemImage: "qrcode")
                }
            }
        }
        .navigationDestination(for: ScannerRoute.self) { route in
            switch route {
            case .history: HistoryScreen()
            case .creator: CreatorScreen()
            case let .record(record): ResultScreen(record: record)
            case let .created(code): CreatedCodeScreen(code: code)
            }
        }
        .navigationDestination(item: $opened) { record in
            ResultScreen(record: record)
        }
        .photosPicker(isPresented: $isChoosingPhoto, selection: $photoItem, matching: .images)
        .confirmationDialog("Codici nella foto", isPresented: isChoosingReading, titleVisibility: .visible) {
            ForEach(photoReadings, id: \.self) { reading in
                Button(CodeContent(reading.raw, symbology: reading.symbology).summary) { open(reading) }
            }
        }
        .alert("Nessun codice in questa foto", isPresented: $isShowingNoCodeAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Prova con una foto più nitida, con il codice intero e dritto.")
        }
        .onAppear { isOnScreen = true }
        .onDisappear {
            isOnScreen = false
            model.disappear()
            // Left during the Closure through a toolbar link: the code stays saved, the camera reads again.
            if saved != nil {
                saved = nil
                isClosing = false
                model.reading = nil
            }
        }
        .task(id: isCameraWanted) {
            if isCameraWanted { await model.appear() } else { model.disappear() }
        }
        .onChange(of: model.reading) { _, reading in
            if let reading { open(reading) }
        }
        .onChange(of: isClosing) { _, isClosing in
            guard !isClosing, let saved else { return }
            self.saved = nil
            show(saved)
        }
        .onChange(of: opened) { _, record in
            // Back from the result: the camera takes the next code.
            if record == nil { model.reading = nil }
        }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            photoItem = nil
            Task { await read(item) }
        }
    }

    /// The metadata line under the title: the app and today's date.
    private var cartiglio: String {
        String(localized: "Sbu · Scanner · \(Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))")
    }

    /// On screen, in the foreground, not behind the photo picker.
    private var isCameraWanted: Bool {
        isOnScreen && scenePhase == .active && !isChoosingPhoto
    }

    private var isChoosingReading: Binding<Bool> {
        Binding { !photoReadings.isEmpty } set: { if !$0 { photoReadings = [] } }
    }

    private func open(_ reading: CodeReading) {
        photoReadings = []
        ScanFeedback.play(sound: playsSound)
        let record = ScanRecord(raw: reading.raw, symbology: reading.symbology)
        if savesHistory {
            modelContext.insert(record)
            try? modelContext.save()
            // Once per scan: the Closure plays its haptic and says its word, then the result opens.
            saved = record
            isClosing = true
        } else {
            unsavedReads += 1
            show(record)
        }
    }

    private func show(_ record: ScanRecord) {
        AccessibilityNotification.Announcement(
            String(localized: "Letto: \(String(localized: record.content.kind.title)), \(record.content.summary)")
        ).post()
        opened = record
    }

    private func read(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let readings = try? await PhotoCodeReader.codes(in: data), !readings.isEmpty
        else {
            isShowingNoCodeAlert = true
            return
        }
        if readings.count == 1 {
            open(readings[0])
        } else {
            photoReadings = readings
        }
    }
}

#Preview("Light") {
    NavigationStack { ScannerScreen() }
        .modelContainer(.preview)
}

#Preview("Dark") {
    NavigationStack { ScannerScreen() }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
