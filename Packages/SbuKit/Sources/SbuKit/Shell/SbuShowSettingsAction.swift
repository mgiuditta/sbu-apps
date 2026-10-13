import SwiftUI

/// Opens the settings sheet of the enclosing `SbuAppShell`.
///
/// Read it from the environment and call it as a function, as with `dismiss`:
///
///     @Environment(\.showSettings) private var showSettings
///
///     Button("Impostazioni", systemImage: "gearshape") {
///         showSettings()
///     }
///
/// Outside a shell it does nothing.
public struct SbuShowSettingsAction: Sendable {
    private let handler: @MainActor @Sendable () -> Void

    /// Creates an action that runs `handler`; the shell makes the one it puts in the environment.
    public init(_ handler: @escaping @MainActor @Sendable () -> Void) {
        self.handler = handler
    }

    /// Opens the settings sheet.
    public func callAsFunction() {
        handler()
    }
}

extension EnvironmentValues {
    /// Opens the settings sheet of the enclosing `SbuAppShell`; does nothing outside one.
    @Entry public var showSettings = SbuShowSettingsAction {}
}
