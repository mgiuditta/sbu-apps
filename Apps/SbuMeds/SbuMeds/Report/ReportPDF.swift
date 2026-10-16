import UIKit

/// The report as an A4 PDF, made on the iPhone: black text on white, as printed paper, page
/// after page. Nothing leaves the device until you share it.
enum ReportPDF {
    static let pageSize = CGSize(width: 595, height: 842)
    static let margin: CGFloat = 48

    static func data(for report: Report, now: Date = .now, calendar: Calendar = .current, locale: Locale = .current) -> Data {
        let blocks = ReportPDF.blocks(for: report, now: now, calendar: calendar, locale: locale)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        let width = pageSize.width - 2 * margin
        return renderer.pdfData { context in
            context.beginPage()
            var y = margin
            for block in blocks {
                let height = ceil(block.text.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height)
                if y + block.spaceBefore + height > pageSize.height - margin {
                    context.beginPage()
                    y = margin
                } else {
                    y += block.spaceBefore
                }
                block.text.draw(with: CGRect(x: margin, y: y, width: width, height: height), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
                y += height
            }
        }
    }

    /// Writes the PDF into a temporary file named for the person and period, for sharing.
    static func file(for report: Report, now: Date = .now, calendar: Calendar = .current) throws -> URL {
        let url = URL.temporaryDirectory.appending(path: report.fileName)
        try data(for: report, now: now, calendar: calendar).write(to: url, options: .atomic)
        return url
    }

    private struct Block {
        let text: NSAttributedString
        let spaceBefore: CGFloat
    }

    private static func blocks(for report: Report, now: Date, calendar: Calendar, locale: Locale) -> [Block] {
        var dayStyle = Date.FormatStyle.dateTime.weekday(.wide).day().month(.wide).year().locale(locale)
        dayStyle.timeZone = calendar.timeZone
        var timeStyle = Date.FormatStyle.dateTime.hour().minute().locale(locale)
        timeStyle.timeZone = calendar.timeZone
        func day(_ day: Day) -> String { day.start(in: calendar).formatted(dayStyle) }
        func percent(_ adherence: Adherence) -> String {
            adherence.rate.map { $0.formatted(.percent.precision(.fractionLength(0)).locale(locale)) } ?? "–"
        }

        var blocks = [
            Block(text: text(String(localized: "Rapporto delle dosi"), .title1, bold: true), spaceBefore: 0),
            Block(text: text(report.personName, .title3, bold: true), spaceBefore: 4),
            Block(text: text(String(localized: "Dal \(day(report.first)) al \(day(report.last))"), .body), spaceBefore: 4),
            Block(text: text(String(localized: "Prese \(report.adherence.taken), saltate \(report.adherence.skipped), non segnate \(report.adherence.missed): \(percent(report.adherence)) delle dosi previste."), .body, bold: true), spaceBefore: 12),
            Block(text: text(String(localized: "Farmaci"), .headline, bold: true), spaceBefore: 20),
        ]
        for medicine in report.medicines {
            let name = medicine.strength.isEmpty ? medicine.name : "\(medicine.name) · \(medicine.strength)"
            blocks.append(Block(text: text(name, .body, bold: true), spaceBefore: 8))
            blocks.append(Block(text: text(medicine.schedule, .footnote, muted: true), spaceBefore: 0))
            let counts = medicine.adherence
            blocks.append(Block(text: text(String(localized: "Prese \(counts.taken), saltate \(counts.skipped), non segnate \(counts.missed) · \(percent(counts))"), .footnote), spaceBefore: 0))
        }
        blocks.append(Block(text: text(String(localized: "Giorno per giorno"), .headline, bold: true), spaceBefore: 20))
        if report.days.isEmpty {
            blocks.append(Block(text: text(String(localized: "Nessuna dose nel periodo."), .body, muted: true), spaceBefore: 8))
        }
        for reportDay in report.days {
            blocks.append(Block(text: text(day(reportDay.day), .subheadline, bold: true), spaceBefore: 12))
            for entry in reportDay.entries {
                let line = "\(entry.dueDate.formatted(timeStyle))  \(entry.name), \(entry.amount) — \(stateText(entry, timeStyle: timeStyle))"
                blocks.append(Block(text: text(line, .footnote), spaceBefore: 2))
            }
        }
        var footerStyle = Date.FormatStyle.dateTime.day().month(.wide).year().hour().minute().locale(locale)
        footerStyle.timeZone = calendar.timeZone
        blocks.append(Block(text: text(String(localized: "Fatto con Sbu Meds il \(now.formatted(footerStyle)). Segnato da chi prende i farmaci o da chi lo assiste: non è un documento medico."), .caption1, muted: true), spaceBefore: 24))
        return blocks
    }

    private static func stateText(_ entry: Report.Entry, timeStyle: Date.FormatStyle) -> String {
        switch entry.state {
        case .taken(let date):
            entry.isExtra ? String(localized: "dose extra") : String(localized: "presa alle \(date.formatted(timeStyle))")
        case .skipped: String(localized: "saltata")
        case .missed: String(localized: "non segnata")
        case .upcoming, .late: String(localized: "da prendere")
        }
    }

    private static func text(_ string: String, _ style: UIFont.TextStyle, bold: Bool = false, muted: Bool = false) -> NSAttributedString {
        // Paper is not the screen: a fixed size, never Dynamic Type, in black or grey.
        let base = UIFont.preferredFont(forTextStyle: style, compatibleWith: UITraitCollection(preferredContentSizeCategory: .large))
        let font = bold ? UIFont(descriptor: base.fontDescriptor.withSymbolicTraits(.traitBold) ?? base.fontDescriptor, size: base.pointSize) : base
        return NSAttributedString(string: string, attributes: [
            .font: font,
            .foregroundColor: muted ? UIColor.darkGray : UIColor.black,
        ])
    }
}
