import Foundation
import SwiftData

/// A made-up computer engineering libretto for previews, screenshots and the "try it" button:
/// never the user's own.
enum SampleLibretto {
    static func insert(into context: ModelContext, now: Date, calendar: Calendar = .current) {
        func day(_ offset: Int) -> Date {
            calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: now)) ?? now
        }
        let exams = [
            Exam(name: String(localized: "Analisi matematica I"), credits: 12, courseYear: 1, kind: .graded, grade: .mark(28), date: day(-400)),
            Exam(name: String(localized: "Fondamenti di informatica"), credits: 12, courseYear: 1, kind: .graded, grade: .cumLaude, date: day(-380)),
            Exam(name: String(localized: "Geometria e algebra lineare"), credits: 6, courseYear: 1, kind: .graded, grade: .mark(25), date: day(-300)),
            Exam(name: String(localized: "Lingua inglese"), credits: 3, courseYear: 1, kind: .passFail, isPassed: true, date: day(-290)),
            Exam(name: String(localized: "Fisica I"), credits: 12, courseYear: 1, kind: .graded, grade: .mark(26), date: day(-260)),
            Exam(name: String(localized: "Algoritmi e strutture dati"), credits: 9, courseYear: 2, kind: .graded, grade: .mark(29), date: day(-150)),
            Exam(name: String(localized: "Analisi matematica II"), credits: 6, courseYear: 2, kind: .graded, grade: .mark(24), date: day(-120)),
            Exam(name: String(localized: "Basi di dati"), credits: 9, courseYear: 2, kind: .graded, grade: .mark(30), date: day(-40)),
            Exam(name: String(localized: "Sistemi operativi"), credits: 9, courseYear: 2, kind: .graded, date: day(12)),
            Exam(name: String(localized: "Reti di calcolatori"), credits: 6, courseYear: 2, kind: .graded, date: day(33)),
            Exam(name: String(localized: "Ingegneria del software"), credits: 9, courseYear: 3, kind: .graded, date: nil),
        ]
        for exam in exams {
            context.insert(exam)
        }
        let lessons = [
            Lesson(title: String(localized: "Sistemi operativi"), room: "Aula 3.1", weekday: 2, startMinutes: 9 * 60, endMinutes: 11 * 60),
            Lesson(title: String(localized: "Reti di calcolatori"), room: "Aula 2.4", weekday: 2, startMinutes: 14 * 60, endMinutes: 16 * 60),
            Lesson(title: String(localized: "Sistemi operativi"), room: "Laboratorio", weekday: 4, startMinutes: 10 * 60 + 30, endMinutes: 12 * 60 + 30),
            Lesson(title: String(localized: "Reti di calcolatori"), room: "Aula 2.4", weekday: 5, startMinutes: 8 * 60 + 30, endMinutes: 10 * 60 + 30),
            Lesson(title: String(localized: "Ingegneria del software"), room: "Aula 1.2", weekday: 6, startMinutes: 11 * 60, endMinutes: 13 * 60),
        ]
        for lesson in lessons {
            context.insert(lesson)
        }
        try? context.save()
    }
}
