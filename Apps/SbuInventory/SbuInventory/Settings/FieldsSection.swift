import SbuKit
import SwiftUI

/// Settings → the custom fields every item has.
struct FieldsSection: View {
    var body: some View {
        Section {
            NavigationLink {
                FieldDefinitionsView()
            } label: {
                Text("Campi personalizzati")
                    .foregroundStyle(SbuTheme.ink)
            }
            .accessibilityIdentifier("fields")
        } footer: {
            Text("Numero di serie, garanzia, colore: i campi che vuoi in ogni oggetto.")
        }
    }
}

#Preview("Light") {
    NavigationStack {
        Form {
            FieldsSection()
        }
    }
}

#Preview("Dark") {
    NavigationStack {
        Form {
            FieldsSection()
        }
    }
    .preferredColorScheme(.dark)
}
