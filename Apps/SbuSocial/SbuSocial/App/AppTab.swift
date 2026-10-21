/// The five tabs, in SocialLite's order (ADR-0017). The app opens on Home, in the middle.
nonisolated enum AppTab: Hashable {
    case sleep, stats, home, block, settings
}
