/// The screens the habit form's rows push.
nonisolated enum HabitFormRoute: Hashable, Sendable {
    /// Tipo: to do, timed or to avoid.
    case kind
    /// Obiettivo, Limite or Durata, as `HabitDraft.goal` says.
    case goal
    /// Giorni: the schedule.
    case days
    /// Notifiche: the reminder times.
    case notifications
    /// Salute: the link and its measure.
    case health
}
