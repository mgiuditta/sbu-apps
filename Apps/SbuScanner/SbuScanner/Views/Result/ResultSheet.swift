/// The system sheets a result can open.
enum ResultSheet: Identifiable {
    case contact(ContactCard)
    case event(CalendarEvent)

    var id: String {
        switch self {
        case .contact: "contact"
        case .event: "event"
        }
    }
}
