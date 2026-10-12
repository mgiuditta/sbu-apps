import Foundation

/// The SF Symbols a habit can wear, each with the name VoiceOver reads.
nonisolated struct HabitSymbol: Identifiable, Sendable {
    static let all: [HabitSymbol] = [
        HabitSymbol("drop", "Acqua"),
        HabitSymbol("cup.and.saucer", "Tazza"),
        HabitSymbol("fork.knife", "Pasto"),
        HabitSymbol("carrot", "Verdura"),
        HabitSymbol("pills", "Medicine"),
        HabitSymbol("bed.double", "Sonno"),
        HabitSymbol("moon", "Luna"),
        HabitSymbol("sun.max", "Sole"),
        HabitSymbol("alarm", "Sveglia"),
        HabitSymbol("figure.walk", "Camminata"),
        HabitSymbol("figure.run", "Corsa"),
        HabitSymbol("bicycle", "Bicicletta"),
        HabitSymbol("figure.pool.swim", "Nuoto"),
        HabitSymbol("dumbbell", "Pesi"),
        HabitSymbol("figure.yoga", "Yoga"),
        HabitSymbol("figure.mind.and.body", "Meditazione"),
        HabitSymbol("lungs", "Respiro"),
        HabitSymbol("heart", "Cuore"),
        HabitSymbol("brain.head.profile", "Mente"),
        HabitSymbol("book", "Libro"),
        HabitSymbol("books.vertical", "Studio"),
        HabitSymbol("pencil", "Scrittura"),
        HabitSymbol("graduationcap", "Scuola"),
        HabitSymbol("character.book.closed", "Lingue"),
        HabitSymbol("music.note", "Musica"),
        HabitSymbol("guitars", "Strumento"),
        HabitSymbol("paintbrush", "Pittura"),
        HabitSymbol("camera", "Foto"),
        HabitSymbol("leaf", "Natura"),
        HabitSymbol("tree", "Albero"),
        HabitSymbol("pawprint", "Animali"),
        HabitSymbol("house", "Casa"),
        HabitSymbol("shower", "Doccia"),
        HabitSymbol("washer", "Bucato"),
        HabitSymbol("cart", "Spesa"),
        HabitSymbol("banknote", "Risparmio"),
        HabitSymbol("phone", "Telefonata"),
        HabitSymbol("iphone.slash", "Niente telefono"),
        HabitSymbol("envelope", "Posta"),
        HabitSymbol("person.2", "Persone"),
        HabitSymbol("checklist", "Lista"),
        HabitSymbol("clock", "Orario"),
    ]

    /// SF Symbol name.
    let id: String
    let name: LocalizedStringResource

    private init(_ id: String, _ name: LocalizedStringResource) {
        self.id = id
        self.name = name
    }
}
