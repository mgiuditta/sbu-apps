import SbuKit
import SwiftUI

/// Whose medicines today shows, as Medisafe's profile on top: a menu with every person.
struct PersonPicker: View {
    let people: [Person]
    @Binding var selection: UUID?

    var body: some View {
        Menu {
            Picker("Persona", selection: $selection) {
                ForEach(people) { person in
                    Text(person.name).tag(Optional(person.id))
                }
            }
        } label: {
            HStack(spacing: SbuTheme.space2) {
                Image(systemName: "person.crop.circle")
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityHidden(true)
                Text(name)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                if people.count > 1 {
                    Image(systemName: "chevron.down")
                        .font(SbuTheme.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .accessibilityHidden(true)
                }
                Spacer(minLength: 0)
            }
            .frame(minHeight: SbuTheme.controlRoundSm)
            .contentShape(.rect)
        }
        .disabled(people.count < 2)
        .accessibilityLabel(Text("Persona"))
        .accessibilityValue(Text(name))
        .accessibilityIdentifier("personPicker")
    }

    private var name: String {
        people.first { $0.id == selection }?.name ?? ""
    }
}

#Preview("Light") {
    PersonPickerPreview()
}

#Preview("Dark") {
    PersonPickerPreview()
        .preferredColorScheme(.dark)
}

private struct PersonPickerPreview: View {
    @State private var selection: UUID?
    private let people = [Person(name: "Io", order: 0), Person(name: "Luca", order: 1)]

    var body: some View {
        PersonPicker(people: people, selection: Binding { selection ?? people.first?.id } set: { selection = $0 })
            .padding(SbuTheme.space4)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(SbuTheme.paper)
    }
}
