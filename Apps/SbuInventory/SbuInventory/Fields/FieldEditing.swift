/// The field form that is open: a new field, or a new name for one.
enum FieldEditing: Identifiable {
    case create
    case rename(FieldDefinition)

    var id: String {
        switch self {
        case .create: "create"
        case let .rename(definition): definition.uuid.uuidString
        }
    }
}
