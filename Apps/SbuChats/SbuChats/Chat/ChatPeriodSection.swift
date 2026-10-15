import SbuKit
import SwiftUI

/// The period every number on the screen covers: all, recent, or two days you pick.
struct ChatPeriodSection: View {
    @Binding var period: ChatPeriod
    let chat: ChatSummary

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Section {
            Picker(selection: $period.option) {
                ForEach(DateRangeOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            } label: {
                Text("Periodo")
                    .foregroundStyle(SbuTheme.ink)
            }
            // In ink: on this screen the accent belongs to the figure's full stop.
            .tint(SbuTheme.ink)
            .modifier(PeriodPickerStyle(isAccessibilitySize: dynamicTypeSize.isAccessibilitySize))

            if period.option == .custom {
                DatePicker(selection: $period.customStart, in: dayRange, displayedComponents: .date) {
                    Text("Dal").foregroundStyle(SbuTheme.ink)
                }
                DatePicker(selection: $period.customEnd, in: dayRange, displayedComponents: .date) {
                    Text("Al").foregroundStyle(SbuTheme.ink)
                }
            }
        } footer: {
            if period.option != .all, period.option != .custom {
                Text("Fino all'ultimo messaggio della chat, il \(ChatDates.day(chat.lastMessageAt)).")
            }
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }

    private var dayRange: ClosedRange<Date> {
        Calendar.current.startOfDay(for: chat.firstMessageAt) ... chat.lastMessageAt
    }
}

#Preview("Light") {
    @Previewable @State var period = ChatPeriod(chat: .preview)
    List { ChatPeriodSection(period: $period, chat: .preview) }
}

#Preview("Dark") {
    @Previewable @State var period = ChatPeriod(chat: .preview)
    List { ChatPeriodSection(period: $period, chat: .preview) }
        .preferredColorScheme(.dark)
}
