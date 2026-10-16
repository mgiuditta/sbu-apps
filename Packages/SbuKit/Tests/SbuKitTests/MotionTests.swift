import SwiftUI
import Testing
@testable import SbuKit

/// One tempo (ADR-0014), and no movement with Reduce Motion.
struct MotionTests {
    @Test func reduceMotionDropsAnimation() {
        #expect(SbuMotion.animation(SbuMotion.spring, reduceMotion: true) == nil)
        #expect(SbuMotion.animation(SbuMotion.base, reduceMotion: false) == SbuMotion.base)
    }

    @Test func tempoComesFromTokens() {
        #expect(SbuMotion.short == .easeOut(duration: 0.18))
        #expect(SbuMotion.base == .easeInOut(duration: 0.32))
        #expect(SbuMotion.spring == .spring(response: 0.42, dampingFraction: 0.82))
    }

    @Test func hapticsAreTheThreeSigns() {
        #expect(SbuHaptic.allCases.map(\.feedback) == [.selection, .impact(weight: .heavy, intensity: 0.9), .success])
    }
}
