import Foundation
import Testing
@testable import SbuLibretto

struct PlanQueryTests {
    nonisolated static func item(_ name: String, year: Int = 1, credits: Double = 6, _ result: ExamResult, day: Int? = nil) -> PlanItem {
        PlanItem(id: UUID(), name: name, credits: credits, courseYear: year, result: result,
                 date: day.map { Date(timeIntervalSince1970: 1_767_225_600 + Double($0) * 86_400) })
    }

    nonisolated static let items: [PlanItem] = [
        item("Analisi", year: 1, credits: 12, .graded(.mark(28)), day: 10),
        item("Fisica", year: 1, credits: 9, .graded(.cumLaude), day: 30),
        item("Inglese", year: 1, credits: 3, .passed, day: 20),
        item("Geometria", year: 1, credits: 6, .graded(.mark(30)), day: nil),
        item("Reti", year: 2, credits: 6, .pending, day: 90),
        item("Basi di dati", year: 2, credits: 9, .graded(.mark(18)), day: 60),
        item("Sistemi", year: 2, credits: 9, .pending, day: nil),
        item("Tesi", year: 3, credits: 6, .pending),
    ]

    nonisolated struct Case: CustomTestStringConvertible, Sendable {
        let name: String
        let query: PlanQuery
        let expected: [[String]]
        var testDescription: String { name }
    }

    nonisolated static let cases: [Case] = [
        Case(name: "per data, dal più recente; senza data in fondo", query: PlanQuery(),
             expected: [["Fisica", "Inglese", "Analisi", "Geometria"], ["Reti", "Basi di dati", "Sistemi"], ["Tesi"]]),
        Case(name: "per data, dal più vecchio; senza data sempre in fondo", query: PlanQuery(descending: false),
             expected: [["Analisi", "Inglese", "Fisica", "Geometria"], ["Basi di dati", "Reti", "Sistemi"], ["Tesi"]]),
        Case(name: "per voto: lode sopra il 30, idoneità e da sostenere in fondo", query: PlanQuery(sort: .grade),
             expected: [["Fisica", "Geometria", "Analisi", "Inglese"], ["Basi di dati", "Reti", "Sistemi"], ["Tesi"]]),
        Case(name: "per voto crescente", query: PlanQuery(sort: .grade, descending: false),
             expected: [["Analisi", "Geometria", "Fisica", "Inglese"], ["Basi di dati", "Reti", "Sistemi"], ["Tesi"]]),
        Case(name: "per CFU, a parità per nome", query: PlanQuery(sort: .credits),
             expected: [["Analisi", "Fisica", "Geometria", "Inglese"], ["Basi di dati", "Sistemi", "Reti"], ["Tesi"]]),
        Case(name: "solo sostenuti", query: PlanQuery(status: .taken),
             expected: [["Fisica", "Inglese", "Analisi", "Geometria"], ["Basi di dati"]]),
        Case(name: "solo da sostenere", query: PlanQuery(status: .pending), expected: [["Reti", "Sistemi"], ["Tesi"]]),
        Case(name: "solo il secondo anno", query: PlanQuery(courseYear: 2), expected: [["Reti", "Basi di dati", "Sistemi"]]),
        Case(name: "anno senza esami", query: PlanQuery(courseYear: 5), expected: []),
        Case(name: "da sostenere al primo anno: nessuno", query: PlanQuery(status: .pending, courseYear: 1), expected: []),
    ]

    @Test(arguments: cases)
    func groups(_ example: Case) {
        let groups = example.query.groups(Self.items)
        #expect(groups.map { $0.items.map(\.name) } == example.expected)
        #expect(groups.map(\.courseYear) == groups.map(\.courseYear).sorted())
    }

    @Test func yearsAreTheOnesInUse() {
        #expect(PlanQuery.courseYears(in: Self.items) == [1, 2, 3])
        #expect(PlanQuery.courseYears(in: []).isEmpty)
    }

    @Test func namesSortLikeFinder() {
        let items = [Self.item("Analisi 10", .pending), Self.item("Analisi 2", .pending), Self.item("analisi 1", .pending)]
        #expect(PlanQuery(sort: .credits).groups(items).first?.items.map(\.name) == ["analisi 1", "Analisi 2", "Analisi 10"])
    }

    @Test(arguments: PlanStatus.allCases)
    func statusIsAPartition(_ status: PlanStatus) {
        let all = PlanQuery().groups(Self.items).flatMap(\.items).count
        let taken = PlanQuery(status: .taken).groups(Self.items).flatMap(\.items).count
        let pending = PlanQuery(status: .pending).groups(Self.items).flatMap(\.items).count
        #expect(taken + pending == all)
        #expect(PlanQuery(status: status).groups([]).isEmpty)
    }
}
