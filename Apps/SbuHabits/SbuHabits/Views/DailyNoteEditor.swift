import SbuKit
import SwiftUI

/// The Nota del giorno of one habit on one day, as a sheet: the habit's ring and title, the day,
/// the text with its character count, and Fine above the keyboard. Annulla leaves the note as
/// it was; Fine with a blank text removes it.
struct DailyNoteEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.calendar) private var calendar

    let model: HabitsModel
    let habit: Habit
    let day: LogicalDay

    @State private var text: String
    @FocusState private var isFocused: Bool

    @ScaledMetric(relativeTo: .title2) private var ringSize = SbuTheme.space12 * 2

    init(model: HabitsModel, habit: Habit, day: LogicalDay) {
        self.model = model
        self.habit = habit
        self.day = day
        _text = State(initialValue: habit.note(on: day) ?? "")
    }

    /// The ring as it looked that day.
    private var face: HabitRingFace {
        HabitRingFace(habit: habit, progress: HabitProgress(of: habit, today: day, firstWeekday: model.firstWeekday))
    }

    private var isEdited: Bool {
        DailyNote.normalized(text) != habit.note(on: day)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SbuTheme.space6) {
                    header
                    field
                }
                .padding(SbuTheme.space4)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollBounceBehavior(.basedOnSize)
            .background(SbuTheme.surface)
            .safeAreaInset(edge: .bottom) {
                // Above the keyboard with Fine, so the count stays in sight while typing.
                VStack(alignment: .trailing, spacing: SbuTheme.space2) {
                    counter
                    SbuButton("Fine", action: save)
                }
                .padding(.horizontal, SbuTheme.space4)
                .padding(.vertical, SbuTheme.space2)
                .background(SbuTheme.surface)
            }
            .navigationTitle("Nota del giorno")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: cancel)
                }
            }
        }
        // A swipe down would throw the text away: Annulla says it.
        .interactiveDismissDisabled(isEdited)
        .onAppear(perform: focus)
    }

    private var header: some View {
        VStack(spacing: SbuTheme.space2) {
            HabitRing(face: face)
                .frame(width: ringSize, height: ringSize)
                .accessibilityHidden(true)

            Text(habit.title)
                .font(SbuTheme.headline)
            .foregroundStyle(SbuTheme.ink)
                .multilineTextAlignment(.center)

            dayText
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private var dayText: Text {
        if day == model.today {
            Text("Oggi")
        } else {
            Text(day.noon(in: calendar), format: .dateTime.weekday(.wide).day().month(.wide))
        }
    }

    private var field: some View {
        TextField("Com'è andata?", text: $text, axis: .vertical)
            .font(SbuTheme.body)
            .foregroundStyle(SbuTheme.ink)
            .lineLimit(6...)
            .focused($isFocused)
            .padding(SbuTheme.space3)
            .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusLg))
            .accessibilityLabel("Nota")
            .onChange(of: text) { _, newText in
                let limited = DailyNote.limited(newText)
                if limited != newText {
                    text = limited
                }
            }
    }

    private var counter: some View {
        Text(verbatim: "\(text.count.formatted())/\(DailyNote.maxLength.formatted())")
            .font(SbuTheme.footnote)
            .monospacedDigit()
            .foregroundStyle(SbuTheme.inkMuted)
            .fixedSize()
            .frame(maxWidth: .infinity, alignment: .trailing)
            .accessibilityLabel("Caratteri")
            .accessibilityValue(Text("\(text.count) di \(DailyNote.maxLength)"))
    }

    private func focus() {
        isFocused = true
    }

    private func save() {
        model.setNote(text, for: habit, on: day)
        dismiss()
    }

    private func cancel() {
        dismiss()
    }
}

#Preview("Light") {
    DailyNoteEditorPreview()
}

#Preview("Dark") {
    DailyNoteEditorPreview()
        .preferredColorScheme(.dark)
}

private struct DailyNoteEditorPreview: View {
    let model = HabitsModel.preview

    var body: some View {
        var habit = model.habits[0]
        habit.setNote("Venti pagine prima di dormire.", on: model.today)
        return DailyNoteEditor(model: model, habit: habit, day: model.today)
            .tint(SbuTheme.accentHabits)
    }
}
