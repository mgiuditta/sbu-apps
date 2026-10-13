import SbuKit
import SwiftUI

/// The Timer of an Abitudine a tempo, full screen: the habit and its length at the top, its ring
/// filling as time goes by, the time left as the screen's one figure, then Annulla, Pausa or
/// Riprendi, and Segna fatta. At the end the habit is marked and the screen closes.
struct TimerView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let model: HabitsModel

    /// The countdown on screen: kept while the screen slides away after it ends.
    @State private var shown: HabitTimer?

    @ScaledMetric(relativeTo: .largeTitle) private var figureSize = SbuTheme.statHeroSize

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
        .background(SbuTheme.surface)
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
        let symbol = model.habits.first { $0.id == timer.habitID }?.symbol ?? "timer"
        let clock = TimerFormat.clock(for: timer.duration)
        // Ticks on the countdown's own seconds, so the figure turns as each second ends.
        let start = (timer.endDate ?? .now).addingTimeInterval(-Double(timer.duration.components.seconds))
        return VStack(spacing: SbuTheme.space6) {
            header(timer, clock: clock)

            Spacer(minLength: 0)

            TimelineView(.periodic(from: start, by: 1)) { context in
                let remaining = timer.remaining(at: context.date)
                VStack(spacing: SbuTheme.space6) {
                    HabitRing(symbol: symbol, segments: 1, filled: timer.progress(at: context.date), symbolFont: SbuTheme.largeTitle)
                        .frame(maxWidth: SbuTheme.space12 * 5, maxHeight: SbuTheme.space12 * 5)
                        .aspectRatio(1, contentMode: .fit)
                        .animation(reduceMotion ? nil : .linear(duration: 1), value: remaining)

                    figure(remaining, clock: clock)
                }
            }

            Spacer(minLength: 0)

            controls(timer)
        }
        .padding(SbuTheme.space4)
        .padding(.vertical, SbuTheme.space4)
    }

    private func header(_ timer: HabitTimer, clock: Duration.TimeFormatStyle) -> some View {
        HStack(spacing: SbuTheme.space2) {
            Image(systemName: "clock")
                .fontWeight(.medium)
                .imageScale(.medium)
            Text(timer.title)
                .textCase(.uppercase)
                .foregroundStyle(SbuTheme.ink)
            Text(timer.duration, format: clock)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .font(SbuTheme.headline)
        .foregroundStyle(SbuTheme.inkMuted)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(timer.title)
        .accessibilityValue(timer.duration.formatted(TimerFormat.spoken))
        .accessibilityAddTraits(.isHeader)
    }

    private func figure(_ remaining: Duration, clock: Duration.TimeFormatStyle) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(remaining, format: clock)
                .font(SbuTheme.numberFont(size: figureSize))
                .tracking(SbuTheme.statHeroTracking)
                // Tracking also follows the last glyph: give it back, or it eats the full stop's gap.
                .padding(.trailing, -SbuTheme.statHeroTracking)
                .foregroundStyle(SbuTheme.ink)
                .contentTransition(.numericText(countsDown: true))
                .animation(reduceMotion ? nil : .snappy, value: remaining)

            SbuFullStop(fontSize: figureSize)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tempo rimanente")
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

            Button("Segna fatta", systemImage: "checkmark", action: markDone)
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
            .tint(SbuTheme.accentHabits)
    }
}
