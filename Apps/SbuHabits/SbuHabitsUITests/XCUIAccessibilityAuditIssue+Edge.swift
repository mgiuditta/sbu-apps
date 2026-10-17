import XCTest

extension XCUIAccessibilityAuditIssue {
    /// A list row half under the screen's edge or a bar, as a scrolled list always has at large
    /// text sizes: the audit reports it as clipped text without naming an element. Text that is
    /// really cut inside a row comes with its element, and still fails.
    var isRowCutByTheScreenEdge: Bool {
        auditType == .textClipped && element == nil
    }

    /// IBM Plex Mono metadata: SbuScreenTitle's cartiglio, "SBU · ABITUDINI · SAB 17 OTT", and the
    /// OGGI and DOMANI labels in the same face. The audit reads `Font.sbuCartiglio`, which SbuKit
    /// scales with `.caption2`, as clipped and only partly following the text size. Only these
    /// elements are left out; their face and size come from SbuKit, not the app.
    var isCartiglio: Bool {
        guard auditType == .textClipped || auditType == .dynamicType, let label = element?.label else { return false }
        return label.hasPrefix("SBU · ") || ["OGGI", "DOMANI"].contains(label)
    }

    /// SbuFigure's hero, 144 pt or more: fixed on purpose, it narrows and steps down to fit one
    /// line instead of growing with the text size, so the audit reports it as not following it.
    var isHeroFigure: Bool {
        guard auditType == .dynamicType, let element, element.elementType == .staticText else { return false }
        return element.frame.height >= Self.heroFigureHeight
    }

    /// Shorter than the smallest hero figure's line: no other text on screen is this tall.
    private static let heroFigureHeight: CGFloat = 120
}
