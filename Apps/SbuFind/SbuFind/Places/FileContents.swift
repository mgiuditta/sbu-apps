/// What reading a local file found.
nonisolated enum FileContents<Value> {
    /// No file yet, or one too damaged to decode: starting from nothing loses nothing.
    case empty
    case loaded(Value)
    /// The file is there but cannot be read now, as with the iPhone locked before the first
    /// unlock: it must not be taken as empty, nor written over.
    case unavailable
}

extension FileContents: Equatable where Value: Equatable {}

extension FileContents: Sendable where Value: Sendable {}
