/// Where a recording comes from, shown in the sound's info and in Impostazioni → Crediti dei suoni.
/// Every recording is CC0: the credit is a courtesy, the licence does not ask for it.
nonisolated struct SoundCredit: Hashable, Sendable {
    /// The recording's title on its source page, as written by its author.
    let title: String
    let author: String
    /// The source page, where the licence was read.
    let page: String
    let license = "CC0 1.0"
}
