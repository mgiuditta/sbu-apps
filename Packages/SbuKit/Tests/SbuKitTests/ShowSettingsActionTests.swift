import SwiftUI
import Testing
@testable import SbuKit

/// The shell hands its tool screen an action that opens settings, for an app that draws its own
/// gear; outside a shell the action is harmless.
struct ShowSettingsActionTests {
    @Test func callingTheActionRunsItsHandler() {
        let opened = OpenCount()
        let action = SbuShowSettingsAction { opened.value += 1 }

        action()
        action()

        #expect(opened.value == 2)
    }

    @Test func outsideAShellTheActionDoesNothing() {
        let action = EnvironmentValues().showSettings

        action()
    }
}

/// Counts the times settings were opened; on the main actor, as the action runs there.
private final class OpenCount {
    var value = 0
}
