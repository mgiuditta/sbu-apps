/// Where `SbuAppShell` puts the button that opens settings.
public enum SbuSettingsButtonPlacement: Sendable, Equatable {
    /// The gear at the trailing edge of the navigation bar: the default for every app.
    case toolbar
    /// No gear in the navigation bar: the tool screen draws its own button and opens settings
    /// with the `showSettings` environment action.
    case content
}
