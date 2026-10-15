import Foundation

/// Reads WhatsApp's iPhone and Android exports in two passes over the text.
///
/// The first pass only looks at message headers to settle the date order for the whole file,
/// the second builds the messages, joining continuation lines to the message they belong to.
/// Neither keeps the file in memory.
nonisolated struct WhatsAppParser: ChatExportParser {
    /// Where the exported times are: the phone's own time zone, as WhatsApp writes them.
    var calendar: Calendar = .current
    /// The tie-breaker when the dates fit more than one order.
    var preferredOrder: DateOrder = DateOrderDetector.preferredOrder(for: .current)

    /// Returns `ios` or `android`, from how the first message frames its time.
    func parse(_ source: ChatTextSource, progress: (Double) -> Void, emit: (ParsedMessage) throws -> Void) throws -> String {
        // Pass 1: the date order, and the first lines in case the file isn't a chat.
        var detector = DateOrderDetector()
        var firstLine: String?
        var firstHeaderLine: String?
        var firstStyle: MessageHeader.Style?
        try source.forEachLine(progress: { progress($0 * 0.4) }) { line in
            if firstLine == nil, !line.trimmingCharacters(in: .whitespaces).isEmpty { firstLine = String(line.prefix(200)) }
            if let header = WhatsAppLineScanner.header(of: line) {
                detector.add(header)
                if firstHeaderLine == nil {
                    firstHeaderLine = String(line.prefix(200))
                    firstStyle = header.style
                }
            }
        }
        guard detector.headerCount > 0 else {
            if firstLine == nil { throw ImportFailure.noMessages }
            throw ImportFailure.unrecognizedFormat(firstLine: firstLine ?? "")
        }
        guard let order = detector.order(preferring: preferredOrder) else {
            throw ImportFailure.unreadableDates(sampleLine: firstHeaderLine ?? "")
        }

        // Pass 2: the messages.
        var pending: (header: MessageHeader, lines: [String])?
        func flush() throws {
            guard let current = pending else { return }
            pending = nil
            guard let date = date(of: current.header, order: order) else { return }
            let body = current.lines.joined(separator: "\n")
            let (kind, text) = MessageClassifier.classify(sender: current.header.sender, body: body)
            try emit(ParsedMessage(sentAt: date, sender: current.header.sender, kind: kind, text: text))
        }
        try source.forEachLine(progress: { progress(0.4 + $0 * 0.6) }) { line in
            if let header = WhatsAppLineScanner.header(of: line), order.accepts(header.dateFields) {
                try flush()
                pending = (header, [header.body])
            } else {
                pending?.lines.append(line)
            }
        }
        try flush()
        return firstStyle == .bracketed ? "ios" : "android"
    }

    private func date(of header: MessageHeader, order: DateOrder) -> Date? {
        let day = order.components(of: header.dateFields)
        var hour = header.hour
        switch header.meridiem {
        case .am: if hour == 12 { hour = 0 }
        case .pm: if hour < 12 { hour += 12 }
        case nil: break
        }
        let components = DateComponents(year: day.year, month: day.month, day: day.day, hour: hour, minute: header.minute, second: header.second)
        guard let date = calendar.date(from: components),
              calendar.component(.day, from: date) == day.day
        else { return nil }
        return date
    }
}
