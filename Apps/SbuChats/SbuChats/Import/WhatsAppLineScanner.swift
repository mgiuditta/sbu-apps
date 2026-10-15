/// Recognises the first line of a WhatsApp message, in the iPhone and Android formats.
///
/// Tolerant to what locales change: day, month and year in any order and with `/`, `.` or `-`,
/// two- or four-digit years, 12- or 24-hour clocks, seconds or not, `AM`/`a. m.` markers, and the
/// invisible marks WhatsApp adds (U+200E before media lines, U+202F before `PM`).
/// A line it doesn't recognise is the continuation of the message before it.
nonisolated enum WhatsAppLineScanner {
    /// The header of `line`, or `nil` when the line continues the previous message.
    static func header(of line: String) -> MessageHeader? {
        var cursor = ScalarCursor(line)
        cursor.skip(where: { isMark($0) || isSpace($0) })
        let style: MessageHeader.Style = cursor.consume("[") ? .bracketed : .dashed
        cursor.skip(where: isMark)

        guard let first = cursor.number(maxDigits: 4) else { return nil }
        let firstDigits = first.digits
        guard let separator = cursor.next(), "/.-".unicodeScalars.contains(separator),
              let second = cursor.number(maxDigits: 2), cursor.consume(separator),
              let third = cursor.number(maxDigits: 4)
        else { return nil }
        _ = cursor.consume(".")
        // A year has two or four digits, first or last; day and month one or two.
        let yearFirst = firstDigits == 4
        guard firstDigits != 3, yearFirst ? third.digits <= 2 : (third.digits == 2 || third.digits == 4) else { return nil }

        // Between date and time: ", " on most locales, a space on some.
        guard cursor.skip(where: { $0 == "," || isSpace($0) }) > 0 else { return nil }

        guard let hour = cursor.number(maxDigits: 2), cursor.consume(where: isTimeSeparator),
              let minute = cursor.number(maxDigits: 2), minute.digits == 2
        else { return nil }
        var seconds = 0
        if cursor.peek().map(isTimeSeparator) == true, cursor.peek(offset: 1)?.properties.numericType != nil {
            _ = cursor.next()
            guard let value = cursor.number(maxDigits: 2), value.digits == 2 else { return nil }
            seconds = value.value
        }

        // AM/PM in any spelling WhatsApp uses: "PM", "pm", "p.m.", "p. m.".
        let marker = cursor.take(while: { $0.properties.isAlphabetic || $0 == "." || isSpace($0) })
            .filter(\.isLetter)
            .lowercased()
        let meridiem: MessageHeader.Meridiem?
        switch marker {
        case "": meridiem = nil
        case "am", "a": meridiem = .am
        case "pm", "p": meridiem = .pm
        default: return nil
        }

        switch style {
        case .bracketed:
            guard cursor.consume("]") else { return nil }
        case .dashed:
            guard cursor.consume(where: { $0 == "-" || $0 == "\u{2013}" }) else { return nil }
        }
        cursor.skip(where: isSpace)

        let validHour = meridiem == nil ? (0 ... 23).contains(hour.value) : (1 ... 12).contains(hour.value)
        guard validHour, minute.value < 60, seconds < 60, first.value > 0, second.value > 0, third.value >= 0 else { return nil }

        let rest = cursor.remainder
        var sender: String?
        var body = rest
        if let colon = rest.range(of: ": ") {
            let name = cleanName(rest[..<colon.lowerBound])
            if !name.isEmpty {
                sender = name
                body = String(rest[colon.upperBound...])
            }
        }
        return MessageHeader(
            style: style,
            dateFields: [first.value, second.value, third.value],
            firstFieldDigits: firstDigits,
            hour: hour.value,
            minute: minute.value,
            second: seconds,
            meridiem: meridiem,
            sender: sender,
            body: body
        )
    }

    /// Left-to-right and other invisible direction marks, and the byte order mark.
    static func isMark(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x200E, 0x200F, 0xFEFF, 0x202A ... 0x202E, 0x2066 ... 0x2069: true
        default: false
        }
    }

    /// Space, no-break space, narrow no-break space (before PM on iPhone) and thin space.
    static func isSpace(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x20, 0xA0, 0x202F, 0x2009, 0x09: true
        default: false
        }
    }

    private static func isTimeSeparator(_ scalar: Unicode.Scalar) -> Bool {
        scalar == ":" || scalar == "."
    }

    /// The name without direction marks or surrounding spaces.
    private static func cleanName(_ name: Substring) -> String {
        let scalars = name.unicodeScalars.filter { !isMark($0) }
        var cleaned = String(String.UnicodeScalarView(scalars))
        while let first = cleaned.unicodeScalars.first, isSpace(first) { cleaned.unicodeScalars.removeFirst() }
        while let last = cleaned.unicodeScalars.last, isSpace(last) { cleaned.unicodeScalars.removeLast() }
        return cleaned
    }
}

/// Walks the Unicode scalars of a line.
private nonisolated struct ScalarCursor {
    private let scalars: [Unicode.Scalar]
    private var index = 0

    init(_ line: String) {
        scalars = Array(line.unicodeScalars)
    }

    var remainder: String {
        String(String.UnicodeScalarView(scalars[index...]))
    }

    func peek(offset: Int = 0) -> Unicode.Scalar? {
        index + offset < scalars.count ? scalars[index + offset] : nil
    }

    mutating func next() -> Unicode.Scalar? {
        guard index < scalars.count else { return nil }
        defer { index += 1 }
        return scalars[index]
    }

    mutating func consume(_ scalar: Unicode.Scalar) -> Bool {
        consume { $0 == scalar }
    }

    mutating func consume(where matches: (Unicode.Scalar) -> Bool) -> Bool {
        guard let scalar = peek(), matches(scalar) else { return false }
        index += 1
        return true
    }

    @discardableResult
    mutating func skip(where matches: (Unicode.Scalar) -> Bool) -> Int {
        var count = 0
        while let scalar = peek(), matches(scalar) {
            index += 1
            count += 1
        }
        return count
    }

    mutating func take(while matches: (Unicode.Scalar) -> Bool) -> String {
        var taken = String.UnicodeScalarView()
        while let scalar = peek(), matches(scalar) {
            taken.append(scalar)
            index += 1
        }
        return String(taken)
    }

    /// An ASCII number of 1 to `maxDigits` digits, with how many digits it had.
    mutating func number(maxDigits: Int) -> (value: Int, digits: Int)? {
        var value = 0
        var digits = 0
        while digits < maxDigits, let scalar = peek(), ("0" ... "9").contains(scalar) {
            value = value * 10 + Int(scalar.value - 48)
            digits += 1
            index += 1
        }
        // More digits than allowed: not a date or time.
        if let scalar = peek(), ("0" ... "9").contains(scalar) { return nil }
        return digits > 0 ? (value, digits) : nil
    }
}
