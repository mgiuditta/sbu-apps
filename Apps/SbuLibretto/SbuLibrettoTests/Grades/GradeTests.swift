import Testing
@testable import SbuLibretto

struct GradeTests {
    @Test(arguments: [17, 0, -18, 31, 33, 100, Int.min, Int.max])
    func marksOutsideEighteenToThirtyAreNotGrades(_ mark: Int) {
        #expect(Grade(mark: mark) == nil)
        #expect(Grade(mark: mark, cumLaude: true) == nil)
    }

    @Test(arguments: 18...30)
    func everyPassingMarkIsAGrade(_ mark: Int) throws {
        let grade = try #require(Grade(mark: mark))
        #expect(grade.mark == mark)
        #expect(grade.value(cumLaudeValue: 33) == Double(mark))
        #expect(grade.shortText == String(mark))
    }

    @Test(arguments: 18...29)
    func onlyThirtyCanBeCumLaude(_ mark: Int) {
        #expect(Grade(mark: mark, cumLaude: true) == nil)
    }

    @Test(arguments: [30.0, 31, 33, 34.5])
    func cumLaudeIsWorthWhatTheCourseSays(_ value: Double) throws {
        let grade = try #require(Grade(mark: 30, cumLaude: true))
        #expect(grade == .cumLaude)
        #expect(grade.mark == 30)
        #expect(grade.value(cumLaudeValue: value) == value)
        #expect(grade.shortText == "30L")
    }

    @Test func gradesGoFromEighteenToCumLaude() {
        #expect(Grade.ascending.count == 14)
        #expect(Grade.ascending.first == .mark(18))
        #expect(Grade.ascending.last == .cumLaude)
        #expect(Grade.descending.first == .cumLaude)
        #expect(Grade.ascending == Grade.ascending.sorted())
        #expect(Grade.mark(30) < .cumLaude)
        #expect(!(Grade.cumLaude < .mark(30)))
        #expect(!(Grade.cumLaude < .cumLaude))
    }

    @Test func resultsSayWhatCountsWhere() {
        #expect(ExamResult.pending.isDone == false)
        #expect(ExamResult.pending.grade == nil)
        #expect(ExamResult.passed.isDone)
        #expect(ExamResult.passed.grade == nil)
        #expect(ExamResult.graded(.mark(27)).grade == .mark(27))
        #expect(ExamResult.graded(.cumLaude).isDone)
    }
}
