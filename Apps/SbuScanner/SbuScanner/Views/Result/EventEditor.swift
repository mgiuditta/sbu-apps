import EventKit
import EventKitUI
import SwiftUI

/// The system's new-event sheet, filled from the code. From iOS 17 it adds the event without asking for the calendar.
struct EventEditor: UIViewControllerRepresentable {
    let event: CalendarEvent
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let store = EKEventStore()
        let draft = EKEvent(eventStore: store)
        draft.title = event.title
        draft.startDate = event.start
        draft.endDate = event.end ?? event.start.addingTimeInterval(event.isAllDay ? 86_400 : 3_600)
        draft.isAllDay = event.isAllDay
        draft.location = event.location.isEmpty ? nil : event.location
        draft.notes = event.notes.isEmpty ? nil : event.notes
        let controller = EKEventEditViewController()
        controller.eventStore = store
        controller.event = draft
        controller.editViewDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: EKEventEditViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator { dismiss() }
    }

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        private let done: () -> Void

        init(done: @escaping () -> Void) {
            self.done = done
        }

        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            done()
        }
    }
}
