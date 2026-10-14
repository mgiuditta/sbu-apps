import Foundation

/// What the add form holds until you save: plain values, so nothing reaches the store half-typed.
struct SubscriptionDraft {
    var serviceID: String?
    var name = ""
    /// The price as you type it, read in your language and never reformatted under the cursor.
    var priceText = ""
    var currencyCode: String
    var cycleChoice = CycleChoice.monthly
    var customInterval = 2
    var customUnit = BillingUnit.month
    var nextPayment: Date
    var hasTrial = false
    var trialEnd: Date
    var hasFixedCount = false
    var paymentCount = 12
    var reminderDaysBefore: Int? = 1
    var category: SubscriptionCategory?
    var list: SubscriptionList?
    var paymentMethod = ""
    var urlText = ""
    var notes = ""
    var locale = Locale.current

    init(currencyCode: String, today: Date = .now, calendar: Calendar = .current) {
        self.currencyCode = currencyCode
        nextPayment = calendar.startOfDay(for: today)
        trialEnd = calendar.date(byAdding: .day, value: 7, to: calendar.startOfDay(for: today)) ?? today
    }

    init(service: CatalogService, categories: [SubscriptionCategory], currencyCode: String, today: Date = .now, calendar: Calendar = .current) {
        self.init(currencyCode: currencyCode, today: today, calendar: calendar)
        serviceID = service.id
        name = service.name
        cycle = service.cycle
        category = categories.first { $0.key == service.category.rawValue }
    }

    /// Fills the form from a stored subscription. The date is its next payment and the count what's left,
    /// so a plan already part paid keeps its past when you change them.
    init(subscription: Subscription, today: Date = .now, calendar: Calendar = .current) {
        self.init(currencyCode: subscription.currencyCode, today: today, calendar: calendar)
        serviceID = subscription.serviceID
        name = subscription.name
        priceText = subscription.price.formatted(.number.precision(.fractionLength(0...2)).locale(locale))
        cycle = subscription.cycle
        let schedule = subscription.schedule
        let nextIndex = schedule.nextPaymentIndex(onOrAfter: today, in: calendar)
        nextPayment = nextIndex.flatMap { schedule.payment(at: $0, in: calendar) } ?? calendar.startOfDay(for: subscription.startDate)
        if let trialEndDate = subscription.trialEndDate, trialEndDate > today {
            hasTrial = true
            trialEnd = trialEndDate
        }
        if let count = subscription.paymentCount {
            hasFixedCount = true
            paymentCount = max(1, count - (nextIndex ?? count))
        }
        reminderDaysBefore = subscription.reminderDaysBefore
        category = subscription.category
        list = subscription.list
        paymentMethod = subscription.paymentMethod
        urlText = subscription.url?.absoluteString ?? ""
        notes = subscription.notes
        original = Schedule(self)
    }

    /// The scheduling fields as the form opened, to tell whether you changed them.
    private var original: Schedule?

    private struct Schedule: Equatable {
        var cycle: BillingCycle
        var start: Date
        var count: Int?

        init(_ draft: SubscriptionDraft) {
            cycle = draft.cycle
            start = draft.hasTrial ? draft.trialEnd : draft.nextPayment
            count = draft.hasFixedCount && draft.cycle != .once ? max(1, draft.paymentCount) : nil
        }
    }

    var price: Decimal? {
        let text = priceText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, let value = try? Decimal(text, format: Decimal.FormatStyle(locale: locale)), value >= 0 else { return nil }
        return value
    }

    var cycle: BillingCycle {
        get {
            switch cycleChoice {
            case .weekly: .weekly
            case .monthly: .monthly
            case .quarterly: .every(3, .month)
            case .yearly: .yearly
            case .custom: .every(max(1, customInterval), customUnit)
            case .once: .once
            }
        }
        set {
            cycleChoice = CycleChoice(newValue)
            if case let .every(interval, unit) = newValue, cycleChoice == .custom {
                customInterval = interval
                customUnit = unit
            }
        }
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && price != nil
    }

    /// A trial's first paid renewal is the day it ends, so the schedule starts there.
    func makeSubscription() -> Subscription? {
        guard canSave, let price else { return nil }
        let schedule = Schedule(self)
        let subscription = Subscription(name: "", price: price, currencyCode: currencyCode, startDate: schedule.start, cycle: schedule.cycle, paymentCount: schedule.count)
        apply(to: subscription)
        return subscription
    }

    /// Writes the form into `subscription`. The schedule restarts from the date shown only if you changed
    /// the date, the cycle or the count; otherwise its start and past payments stay as they were.
    func apply(to subscription: Subscription) {
        guard canSave, let price else { return }
        let schedule = Schedule(self)
        if schedule != original {
            subscription.startDate = schedule.start
            subscription.cycle = schedule.cycle
            subscription.paymentCount = schedule.count
        }
        subscription.name = name.trimmingCharacters(in: .whitespaces)
        subscription.price = price
        subscription.currencyCode = currencyCode
        subscription.serviceID = serviceID
        subscription.trialEndDate = hasTrial ? trialEnd : nil
        subscription.reminderDaysBefore = reminderDaysBefore
        subscription.category = category
        subscription.list = list
        subscription.paymentMethod = paymentMethod.trimmingCharacters(in: .whitespaces)
        subscription.url = WebPage.url(urlText)
        subscription.notes = notes
    }
}
