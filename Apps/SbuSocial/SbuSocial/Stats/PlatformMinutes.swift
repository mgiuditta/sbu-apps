/// One row of today's list in Statistiche.
nonisolated struct PlatformMinutes: Identifiable {
    let platform: Platform
    let minutes: Int

    var id: Platform { platform }
}
