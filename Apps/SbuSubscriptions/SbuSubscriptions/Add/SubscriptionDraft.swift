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
        let subscription = Subscription(
            name: name.trimmingCharacters(in: .whitespaces),
            price: price,
            currencyCode: currencyCode,
            startDate: hasTrial ? trialEnd : nextPayment,
            cycle: cycle,
            paymentCount: hasFixedCount && cycle != .once ? max(1, paymentCount) : nil
        )
        subscription.serviceID = serviceID
        subscription.trialEndDate = hasTrial ? trialEnd : nil
        subscription.reminderDaysBefore = reminderDaysBefore
        subscription.category = category
        subscription.list = list
        subscription.paymentMethod = paymentMethod.trimmingCharacters(in: .whitespaces)
        subscription.url = URL(string: urlText.trimmingCharacters(in: .whitespaces)).flatMap { $0.scheme == nil ? URL(string: "https://\($0.absoluteString)") : $0 }
        subscription.notes = notes
        return subscription
    }
}
