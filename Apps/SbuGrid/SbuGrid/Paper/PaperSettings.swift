import CoreGraphics
import Foundation

/// The sheet the drawing goes on and the size of its cells: from these come the crop's shape
/// and the grid's columns and rows, as GridArt does with paper formats and cells in cm or inches.
///
/// Lengths are kept in the chosen unit, on its step; changing the unit converts them to the
/// nearest step of the new one. Every value is clamped, also when decoded.
nonisolated struct PaperSettings: Codable, Hashable, Sendable {
    var format = PaperFormat.free
    var orientation = PaperOrientation.portrait
    private var storedUnit: LengthUnit
    private var storedCellLength: Double
    private var storedCustomWidth: Double
    private var storedCustomHeight: Double

    /// A sheet in the unit `locale` measures in: 2 cm cells and a 30 × 40 cm custom sheet, or
    /// ¾-inch cells and a 12 × 16 inch one.
    init(locale: Locale = .autoupdatingCurrent) {
        let unit = LengthUnit.preferred(for: locale)
        storedUnit = unit
        switch unit {
        case .centimeters:
            storedCellLength = 2
            storedCustomWidth = 30
            storedCustomHeight = 40
        case .inches:
            storedCellLength = 0.75
            storedCustomWidth = 12
            storedCustomHeight = 16
        }
    }

    /// The side of a cell, in `unit`.
    var cellLength: Double {
        get { storedCellLength }
        set { storedCellLength = LengthUnit.snap(newValue, step: unit.step, within: unit.cellRange) }
    }

    /// The custom sheet's width in portrait, in `unit`.
    var customWidth: Double {
        get { storedCustomWidth }
        set { storedCustomWidth = LengthUnit.snap(newValue, step: unit.step, within: unit.sideRange) }
    }

    /// The custom sheet's height in portrait, in `unit`.
    var customHeight: Double {
        get { storedCustomHeight }
        set { storedCustomHeight = LengthUnit.snap(newValue, step: unit.step, within: unit.sideRange) }
    }

    /// The unit of every length; a new one converts each length to its nearest step.
    var unit: LengthUnit {
        get { storedUnit }
        set {
            guard newValue != storedUnit else { return }
            storedCellLength = storedUnit.convert(storedCellLength, to: newValue, within: newValue.cellRange)
            storedCustomWidth = storedUnit.convert(storedCustomWidth, to: newValue, within: newValue.sideRange)
            storedCustomHeight = storedUnit.convert(storedCustomHeight, to: newValue, within: newValue.sideRange)
            storedUnit = newValue
        }
    }

    /// The sheet as it stands, in `unit`; `nil` without a sheet.
    var size: (width: Double, height: Double)? {
        let portrait: (width: Double, height: Double)
        switch format {
        case .free:
            return nil
        case .custom:
            portrait = (customWidth, customHeight)
        default:
            guard let millimeters = format.portraitMillimeters else { return nil }
            portrait = (millimeters.width / 10 / unit.centimeters, millimeters.height / 10 / unit.centimeters)
        }
        switch orientation {
        case .portrait: return portrait
        case .landscape: return (portrait.height, portrait.width)
        }
    }

    /// Width over height of the sheet, the shape of the crop; `nil` for a free crop.
    var aspectRatio: Double? {
        guard let size, size.height > 0 else { return nil }
        return size.width / size.height
    }

    /// Cells of `cellLength` on the sheet; `nil` without a sheet, when the grid settings decide.
    var cellRule: CellRule? {
        guard let size else { return nil }
        return .physical(cellLength: cellLength, paperWidth: size.width)
    }

    /// The PDF page, in points; `nil` without a sheet.
    var pageSize: CGSize? {
        guard let size else { return nil }
        return CGSize(width: size.width * unit.points, height: size.height * unit.points)
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case format, orientation, unit, cellLength, customWidth, customHeight
    }

    /// A missing or unknown value takes the default for the stored unit; lengths are clamped.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let unit = (try? container.decodeIfPresent(LengthUnit.self, forKey: .unit)) ?? LengthUnit.preferred(for: .autoupdatingCurrent)
        var settings = PaperSettings(locale: Locale(identifier: unit == .inches ? "en_US" : "it_IT"))
        settings.format = (try? container.decodeIfPresent(PaperFormat.self, forKey: .format)) ?? settings.format
        settings.orientation = (try? container.decodeIfPresent(PaperOrientation.self, forKey: .orientation)) ?? settings.orientation
        if let length = try? container.decodeIfPresent(Double.self, forKey: .cellLength) {
            settings.cellLength = length
        }
        if let width = try? container.decodeIfPresent(Double.self, forKey: .customWidth) {
            settings.customWidth = width
        }
        if let height = try? container.decodeIfPresent(Double.self, forKey: .customHeight) {
            settings.customHeight = height
        }
        self = settings
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(format, forKey: .format)
        try container.encode(orientation, forKey: .orientation)
        try container.encode(unit, forKey: .unit)
        try container.encode(cellLength, forKey: .cellLength)
        try container.encode(customWidth, forKey: .customWidth)
        try container.encode(customHeight, forKey: .customHeight)
    }
}
