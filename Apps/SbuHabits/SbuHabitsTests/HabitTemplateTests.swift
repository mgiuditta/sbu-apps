import Foundation
import Testing
@testable import SbuHabits

struct HabitTemplateTests {
    private static let italian = Locale(identifier: "it_IT")
    private static let american = Locale(identifier: "en_US")
    nonisolated private static let ids = HabitTemplate.all.map(\.id)

    private let store = HabitsStore(url: .temporaryDirectory.appending(path: "HabitTemplateTests-\(UUID().uuidString).json"))

    private static func template(_ id: String) throws -> HabitTemplate {
        try #require(HabitTemplate.withID(id))
    }

    private static func resolve(_ resource: LocalizedStringResource, _ locale: Locale) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }

    // MARK: Catalog

    @Test func idsAreUnique() {
        #expect(Set(Self.ids).count == Self.ids.count)
    }

    @Test(arguments: HabitTemplateCategory.allCases)
    func everyTabHasEightToTwelveTemplates(category: HabitTemplateCategory) {
        #expect((8...12).contains(HabitTemplate.of(category).count))
    }

    @Test(arguments: ids)
    func everySymbolIsInTheCatalog(id: String) throws {
        let template = try Self.template(id)
        #expect(HabitSymbol.named(template.symbol) != nil, "\(template.symbol)")
    }

    @Test(arguments: ids)
    func everyTitleIsTranslatedAndFits(id: String) throws {
        let template = try Self.template(id)
        let italian = Self.resolve(template.title, Self.italian)
        let english = Self.resolve(template.title, Self.american)

        #expect(english != italian, "\(italian) has no English")
        #expect(italian.count <= Habit.maxTitleLength)
        #expect(english.count <= Habit.maxTitleLength)
    }

    @Test(arguments: ids)
    func aTemplateKindMatchesItsTab(id: String) throws {
        let template = try Self.template(id)
        switch template.category {
        case .general:
            #expect(template.kind == .toDo && template.health == nil)
        case .health:
            #expect(template.kind == .toDo && template.health != nil)
        case .eating:
            #expect(template.kind == .toDo)
        case .timed:
            #expect(template.kind == .timed && template.health == nil)
        case .toAvoid:
            #expect(template.kind == .toAvoid && template.health == nil)
        }
    }

    @Test(arguments: HabitTemplate.all.filter { $0.health != nil }.map(\.id))
    func saluteGoalsAreOnesTheFormOffers(id: String) throws {
        let link = try #require(try Self.template(id).health)
        #expect(HealthMeasure.allCases.contains(link.measure))
        #expect(link.measure.goalRange.contains(link.goal))
        #expect(link.goal.truncatingRemainder(dividingBy: link.measure.goalStep) == 0)
    }

    @Test(arguments: HabitTemplate.of(.timed).map(\.id))
    func durationsAreOnesTheFormOffers(id: String) throws {
        let template = try Self.template(id)
        let draft = template.draft(today: LogicalDay(.now))
        #expect(draft.durationChoices.count == HabitDraft(habit: nil, today: LogicalDay(.now)).durationChoices.count)
        #expect(draft.durationChoices.contains(template.timerMinutes))
    }

    @Test(arguments: HabitTemplate.of(.toAvoid).map(\.id))
    func limitsAreOnesTheFormOffers(id: String) throws {
        #expect(Habit.limitRange.contains(try Self.template(id).limit))
    }

    // MARK: Drafts

    @Test func aTemplateFillsTheForm() throws {
        let draft = try Self.template("health.walk").draft(today: LogicalDay(.now), locale: Self.american)

        #expect(draft.title == "Walk")
        #expect(draft.symbol == "figure.walk")
        #expect(draft.kind == .toDo)
        #expect(draft.goal == .health)
        #expect(draft.healthLink == HealthLink(measure: .steps, goal: 8_000))
        #expect(draft.schedule() == .everyDay)
    }

    @Test func aTemplateWithoutSaluteIsMarkedByHand() throws {
        let draft = try Self.template("health.walk").draft(today: LogicalDay(.now), canLinkHealth: false)

        #expect(draft.healthLink == nil)
        #expect(draft.goal == .timesPerDay)
    }

    @Test func aTemplateSetsItsDays() throws {
        let draft = try Self.template("general.plants").draft(today: LogicalDay(.now))

        #expect(draft.scheduleKind == .weekdays)
        #expect(draft.schedule() == .weekdays([2, 5]))
        #expect(draft.daysSummary(locale: Self.italian) == "lun e gio")
    }

    @Test(arguments: ids)
    func savingATemplateAddsTheHabitItDescribes(id: String) throws {
        let template = try Self.template(id)
        let model = HabitsModel(store: store)
        let draft = template.draft(today: model.today, locale: Self.italian)
        #expect(draft.canSave)

        model.add(title: draft.resolvedTitle(locale: Self.italian), symbol: draft.symbol, timesPerDay: draft.timesPerDay, schedule: draft.schedule(), limit: draft.savedLimit, health: draft.healthLink, timerMinutes: draft.savedTimerMinutes)

        let habit = try #require(model.habits.first)
        #expect(habit.title == template.title.key)
        #expect(habit.symbol == template.symbol)
        #expect(habit.schedule == template.schedule)
        #expect(habit.health == template.health)
        #expect(habit.limit == (template.kind == .toAvoid ? template.limit : nil))
        #expect(habit.timerMinutes == (template.kind == .timed ? template.timerMinutes : nil))
        if template.kind == .toDo, template.health == nil, template.schedule.period == nil {
            #expect(habit.timesPerDay == template.timesPerDay)
        }
    }

    @Test(arguments: [
        (HabitTemplateCategory.general, HabitKind.toDo, false),
        (.health, .toDo, true),
        (.eating, .toDo, false),
        (.timed, .timed, false),
        (.toAvoid, .toAvoid, false),
    ])
    func personalizzataStartsTheTabsKind(category: HabitTemplateCategory, kind: HabitKind, linksHealth: Bool) {
        let draft = category.customDraft(today: LogicalDay(.now))

        #expect(draft.kind == kind)
        #expect(draft.linksHealth == linksHealth)
        #expect(draft.title.isEmpty)
        #expect(HabitSymbol.named(draft.symbol) != nil)
    }

    @Test func routesOpenTheirDraft() {
        let today = LogicalDay(.now)

        #expect(AddHabitRoute.custom(.toAvoid).draft(today: today).kind == .toAvoid)
        #expect(AddHabitRoute.template("timed.read").draft(today: today).timerMinutes == 20)
        #expect(AddHabitRoute.template("not.a.template").draft(today: today) == HabitDraft(habit: nil, today: today))
    }
}
