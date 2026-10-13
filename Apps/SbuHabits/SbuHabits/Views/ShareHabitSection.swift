import SbuKit
import SwiftUI

/// The form's Condividi row, under Notifiche, for a habit already saved: it opens the system
/// iCloud sharing screen, to invite people, see who has it and stop sharing. The row says how
/// many people have it. Without iCloud it is off, and the footer says why.
struct ShareHabitSection: View {
    let sharing: HabitSharing
    let habit: Habit

    @State private var isPreparing = false
    @State private var isShowingFailure = false

    private var value: String {
        guard let count = sharing.participantCount(of: habit), count > 0 else { return "" }
        return count == 1 ? String(localized: "Condivisa con 1 persona") : String(localized: "Condivisa con \(count) persone")
    }

    private var footer: LocalizedStringKey {
        sharing.isAvailable
            ? "Chi inviti vede l'abitudine e lo storico, non i promemoria né le note."
            : "Per condividere, accedi a iCloud nelle Impostazioni dell'iPhone."
    }

    var body: some View {
        Section {
            Button(action: share) {
                HabitFormRow(title: "Condividi", systemImage: "person.2", value: value)
                    .overlay(alignment: .trailing) {
                        if isPreparing {
                            ProgressView()
                        }
                    }
            }
            .disabled(sharing.isAvailable == false || isPreparing)
        } footer: {
            Text(footer)
        }
        .listRowBackground(SbuTheme.surfaceRaised)
        .alert("Non riesco a condividere l'abitudine", isPresented: $isShowingFailure) {
            // No actions: the system adds its own OK.
        } message: {
            Text("Controlla la connessione e riprova.")
        }
        .task {
            await sharing.refreshShares()
        }
    }

    private func share() {
        isPreparing = true
        Task {
            defer { isPreparing = false }
            do {
                let share = try await sharing.prepareShare(of: habit)
                let id = habit.id
                CloudSharingPresenter.present(share, title: habit.title) { stopped in
                    Task {
                        await sharing.sharingDidChange(for: id, stopped: stopped)
                    }
                }
            } catch {
                isShowingFailure = true
            }
        }
    }
}

#Preview("Light") {
    let model = HabitsModel.preview
    Form {
        ShareHabitSection(sharing: .preview(model: model), habit: model.habits[1])
        ShareHabitSection(sharing: .preview(model: model, isAvailable: false), habit: model.habits[1])
    }
    .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    let model = HabitsModel.preview
    Form {
        ShareHabitSection(sharing: .preview(model: model), habit: model.habits[1])
        ShareHabitSection(sharing: .preview(model: model, isAvailable: false), habit: model.habits[1])
    }
    .tint(SbuTheme.accentHabits)
    .preferredColorScheme(.dark)
}
