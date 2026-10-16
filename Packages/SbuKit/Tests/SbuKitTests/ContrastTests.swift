import SwiftUI
import Testing
@testable import SbuKit

/// The contrast pairs the design system promises, checked on the shipped color assets in both themes.
struct ContrastTests {
    private static let grounds = [("paper", SbuTheme.paper), ("surfaceRaised", SbuTheme.surfaceRaised)]

    private static let accents: [(String, SbuAccent)] = [
        ("habits", .habits), ("subscriptions", .subscriptions), ("level", .level), ("scanner", .scanner),
        ("clean", .clean), ("find", .find), ("fuel", .fuel), ("grid", .grid), ("inventory", .inventory),
        ("libretto", .libretto), ("meds", .meds), ("moon", .moon), ("noise", .noise), ("remote", .remote),
        ("shrink", .shrink), ("speed", .speed), ("tidy", .tidy), ("chats", .chats),
    ]

    @Test(arguments: [ColorScheme.light, .dark])
    func textOnPaperMeetsWCAG(scheme: ColorScheme) {
        for (name, ground) in Self.grounds {
            #expect(ratio(SbuTheme.ink, ground, scheme) >= 7, "ink on \(name)")
            #expect(ratio(SbuTheme.inkMuted, ground, scheme) >= SbuContrast.text, "inkMuted on \(name)")
        }
    }

    /// The waiting full stop is `inkMuted`: a graphic, 3:1.
    @Test(arguments: [ColorScheme.light, .dark])
    func waitingFullStopIsVisible(scheme: ColorScheme) {
        for (name, ground) in Self.grounds {
            #expect(ratio(SbuTheme.inkMuted, ground, scheme) >= SbuContrast.graphic, "waiting on \(name)")
        }
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func setFullStopIsVisible(scheme: ColorScheme) {
        for (app, accent) in Self.accents {
            for (name, ground) in Self.grounds {
                #expect(ratio(accent.base, ground, scheme) >= SbuContrast.graphic, "\(app) on \(name)")
            }
            #expect(ratio(accent.onInk, SbuTheme.ink, scheme) >= SbuContrast.graphic, "\(app) on ink")
        }
    }

    /// The Closure's word is `paper` on the ink block.
    @Test(arguments: [ColorScheme.light, .dark])
    func closureWordIsReadable(scheme: ColorScheme) {
        #expect(ratio(SbuTheme.paper, SbuTheme.ink, scheme) >= 7)
    }

    @Test func ratioMatchesWCAGExtremes() {
        let black = Color.black.resolve(in: EnvironmentValues())
        let white = Color.white.resolve(in: EnvironmentValues())
        #expect(abs(SbuContrast.ratio(black, white) - 21) < 0.01)
        #expect(SbuContrast.ratio(white, white) == 1)
        #expect(SbuContrast.ratio(white, black) == SbuContrast.ratio(black, white))
    }

    private func ratio(_ first: Color, _ second: Color, _ scheme: ColorScheme) -> Double {
        var environment = EnvironmentValues()
        environment.colorScheme = scheme
        return SbuContrast.ratio(first.resolve(in: environment), second.resolve(in: environment))
    }
}
