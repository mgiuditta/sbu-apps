import SbuKit
import SwiftUI

/// The item form's tags: the ones on the item, a field to add one, and the tags you already used.
struct TagsSection: View {
    @Binding var tags: [String]
    /// Every tag in the inventory, for suggestions.
    let allTags: [String]

    @State private var newTag = ""

    var body: some View {
        let suggestions = Array(TagList.suggestions(for: newTag, among: allTags, excluding: tags).prefix(8))
        Section {
            if !tags.isEmpty {
                FlowLayout(spacing: SbuTheme.space2) {
                    ForEach(tags, id: \.self) { tag in
                        TagChip(tag: tag) { tags.removeAll { $0 == tag } }
                    }
                }
                .padding(.vertical, SbuTheme.space1)
            }
            TextField("Aggiungi un tag", text: $newTag)
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                .onSubmit(add)
                .accessibilityIdentifier("newTag")
            if !suggestions.isEmpty {
                FlowLayout(spacing: SbuTheme.space2) {
                    ForEach(suggestions, id: \.self) { tag in
                        Button {
                            tags = TagList.normalized(tags + [tag])
                            newTag = ""
                        } label: {
                            Text(tag)
                                .font(SbuTheme.subheadline)
                                .padding(.horizontal, SbuTheme.space3)
                                .padding(.vertical, SbuTheme.space1)
                                .background(SbuTheme.surfaceSunken, in: .rect(cornerRadius: SbuTheme.radiusPill))
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel(Text("Aggiungi il tag \(tag)"))
                    }
                }
                .padding(.vertical, SbuTheme.space1)
            }
        } header: {
            Text("Tag")
        }
    }

    private func add() {
        tags = TagList.normalized(tags + [newTag])
        newTag = ""
    }
}

#Preview("Light") {
    @Previewable @State var tags = ["attrezzi"]
    Form {
        TagsSection(tags: $tags, allTags: ["attrezzi", "garage", "cucina"])
    }
}

#Preview("Dark") {
    @Previewable @State var tags = ["attrezzi"]
    Form {
        TagsSection(tags: $tags, allTags: ["attrezzi", "garage", "cucina"])
    }
    .preferredColorScheme(.dark)
}
