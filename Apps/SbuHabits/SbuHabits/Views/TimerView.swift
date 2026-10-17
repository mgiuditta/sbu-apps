import SbuKit
import SwiftUI

/// The Timer of an Abitudine a tempo, full screen on paper: the habit as the title with its
/// length in the cartiglio, the time left as the screen's one figure, then Annulla, Pausa or
/// Riprendi, and Segna come fatta. The full stop waits while the time runs and is set at the end,
/// when the habit is marked and the screen closes.
struct TimerView: View {
    let model: HabitsModel

    /// The countdown on screen: kept while the screen slides away after it ends.
    @State private var shown: HabitTimer?

    init(model: HabitsModel) {
        self.model = model
        _shown = State(initialValue: model.timer)
    }

    var body: some View {
        Group {
            if let timer = model.timer ?? shown {
                content(for: timer)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sbuPaper(grid: true)
        .onChange(of: model.timer) { _, timer in
            if let timer {
                shown = timer
            }
        }
        // Wakes at the end, also after the app comes back: a sleep counts the time in between.
        .task(id: model.timer?.endDate) {
            await finishAtTheEnd()
        }
    }

    private func content(for timer: HabitTimer) -> some View {
        let clock = TimerFormat.clock(for: timer.duration)
        // Ticks on the countdown's own seconds, so the figure turns as each second ends.
        let start = (timer.endDate ?? .now).addingTimeInterval(-Double(timer.duration.components.seconds))
        return VStack(alignment: .leading, spacing: SbuTheme.space6) {
            SbuScreenTitle(verbatim: timer.title, cartiglio: Self.cartiglio(timer))

            // Right under the title, never between spacers: the figure snaps to the grid, and a
            // spacer that gave way to the snap would move it off the line again.
            TimelineView(.periodic(from: start, by: 1)) { context in
                figure(timer.remaining(at: context.date), clock: clock)
            }

            Spacer(minLength: 0)

            controls(timer)
        }
        .padding(SbuTheme.space4)
        .padding(.vertical, SbuTheme.space4)
    }

    /// "Sbu · A tempo · 10 min".
    private static func cartiglio(_ timer: HabitTimer) -> String {
        String(localized: "Sbu · A tempo · \(timer.duration.formatted(TimerFormat.length))")
    }

    /// The time left: waiting while it runs, set once it reaches zero.
    private func figure(_ remaining: Duration, clock: Duration.TimeFormatStyle) -> some View {
        SbuFigure(
            value: remaining.formatted(clock),
            fullStop: remaining <= .zero ? .set : .waiting,
            accessibilityLabel: Text("Tempo rimanente")
        )
        .accessibilityValue(remaining.formatted(TimerFormat.spoken))
        .accessibilityAddTraits(.updatesFrequently)
    }

    private func controls(_ timer: HabitTimer) -> some View {
        HStack {
            Button("Annulla", systemImage: "xmark", action: cancel)
                .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRound))

            Spacer()

            Group {
                if timer.isRunning {
                    Button("Pausa", systemImage: "pause.fill", action: togglePause)
                } else {
                    Button("Riprendi", systemImage: "play.fill", action: togglePause)
                }
            }
            .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRoundLg, isProminent: true))

            Spacer()

            Button("Segna come fatta", systemImage: "checkmark", action: markDone)
                .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRound))
        }
        .labelStyle(.iconOnly)
        .padding(.horizontal, SbuTheme.space4)
        // Nothing to do once it ended, while the screen closes.
        .disabled(model.timer == nil)
    }

    /// Marks the habit when the countdown ends with the screen open; a pause cancels the wait.
    private func finishAtTheEnd() async {
        while let end = model.timer?.endDate {
            if model.finishTimerIfEnded() { return }
            do {
                try await Task.sleep(for: .seconds(max(end.timeIntervalSinceNow, 0.05)))
            } catch {
                return
            }
        }
    }

    private func cancel() {
        model.cancelTimer()
    }

    private func togglePause() {
        model.toggleTimerPause()
    }

    private func markDone() {
        model.markTimerDone()
    }
}

#Preview("Light") {
    TimerViewPreview()
}

#Preview("Dark") {
    TimerViewPreview()
        .preferredColorScheme(.dark)
}

private struct TimerViewPreview: View {
    @State private var model: HabitsModel = {
        let model = HabitsModel.preview
        model.add(title: "Meditare", symbol: "brain.head.profile", timerMinutes: 3)
        if let meditating = model.habits.last {
            model.startTimer(for: meditating)
        }
        return model
    }()

    var body: some View {
        TimerView(model: model)
            .tint(SbuTheme.ink)
    }
}
