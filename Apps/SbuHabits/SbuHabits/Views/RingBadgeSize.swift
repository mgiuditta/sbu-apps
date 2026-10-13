import CoreGraphics
import SbuKit

/// The side of the round badge on a ring's stroke, at the bottom right: play on an Abitudine a
/// tempo, the owner of an Abitudine condivisa. On a small ring, as on a short iPhone's full page,
/// the usual badge would cover a third of it, so it shrinks; play keeps a 44 pt touch target.
enum RingBadgeSize {
    /// Rings smaller than this get the small badge.
    static let smallRingThreshold = SbuTheme.space12 * 2

    /// The badge's visible side for a ring of `ringSide`.
    static func side(forRingSide ringSide: CGFloat) -> CGFloat {
        ringSide < smallRingThreshold ? SbuTheme.space8 : SbuTheme.controlRoundSm
    }

    /// How far the badge's centre sits right of and below the ring's centre: on the stroke.
    static func offset(inRingOfSide ringSide: CGFloat) -> CGFloat {
        ringSide / 2 * (0.5).squareRoot()
    }
}
