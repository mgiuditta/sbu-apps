extension WidgetSnapshot {
    /// The figures of the libretto and its next five sittings.
    nonisolated init(transcript: Transcript, countdown: ExamCountdown) {
        self.init(average: transcript.weightedAverage, change: transcript.lastChange, earnedCredits: transcript.earnedCredits,
                  totalCredits: transcript.rules.totalCredits, base: transcript.base?.value,
                  nextExams: countdown.upcoming.prefix(5).map { NextExam(name: $0.name, date: $0.date) })
    }
}
