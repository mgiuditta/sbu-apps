import Foundation

/// Pauses and resumes the saved countdown from the buttons of its Live Activity. Their intents
/// run in the app's process: the change goes to the App Group, then the app's model reads it
/// back, which plans the notification at the end again and moves the activity and the Timer.
enum TimerControl {
    /// Set by the app at launch: reads the saved countdown again. Without it, as in the widget
    /// extension, the notification and the activity follow here.
    static var reloadApp: (() -> Void)?

    /// Pauses (`paused`) or resumes the countdown of `habitID`, saved in `store`, at `now`.
    static func setPaused(_ paused: Bool, habitID: String, store: HabitTimerStore = .shared, now: Date = .now) {
        let changed = change(store.load(), paused: paused, habitID: habitID, now: now)
        if let changed {
            store.save(changed)
        }
        if let reloadApp {
            reloadApp()
        } else if let changed {
            let file = (try? HabitsStore.shared.load()) ?? HabitsFile()
            ReminderScheduler.replace(with: ReminderPlan.reminders(for: file.habits, timer: changed, now: now, startHour: file.startHour, calendar: .current))
            TimerActivity.apply(.follow(changed))
        }
    }

    /// The countdown `timer` paused or resumed at `now`, or `nil` when nothing changes: it is
    /// another habit's, it is already so, or it has ended, which the app marks done.
    nonisolated static func change(_ timer: HabitTimer?, paused: Bool, habitID: String, now: Date) -> HabitTimer? {
        guard var timer, timer.habitID.uuidString == habitID, timer.isRunning == paused, timer.isFinished(at: now) == false else {
            return nil
        }
        if paused {
            timer.pause(at: now)
        } else {
            timer.resume(at: now)
        }
        return timer
    }
}
