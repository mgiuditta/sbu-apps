import Foundation

// Compiled in Release too: #Preview bodies are, and they use it.
extension ReceivedHabitsFile {
    /// One habit someone shares: running, done most of the last three weeks, not yet today.
    static func demo(today: LogicalDay) -> ReceivedHabitsFile {
        var habit = Habit(id: UUID(uuidString: "5B1E0C2A-7F3D-4C1B-9E2A-1D3F5A7B9C0E") ?? UUID(), title: "Correre", symbol: "figure.run", createdOn: today - 20)
        for offset in 1...20 where offset % 6 != 0 {
            habit.mark(on: today - offset, hour: 7)
        }
        let received = ReceivedHabit(key: "demo|habit-\(habit.id.uuidString)", snapshot: SharedHabitSnapshot(habit: habit, startHour: 0))
        return ReceivedHabitsFile(habits: [received])
    }
}
