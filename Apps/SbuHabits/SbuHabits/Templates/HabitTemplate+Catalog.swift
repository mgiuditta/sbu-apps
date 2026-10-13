import Foundation

// The Modelli of Aggiungi abitudine, by tab, in the order the sheet shows them. Each symbol is
// in `HabitSymbol.all`, each Salute measure in `HealthMeasure`, each goal within its range.
// Each Italian title is in Localizable.xcstrings with the English one given here; titles carry
// no amounts, which the form's rows show and the person may change.

nonisolated extension HabitTemplate {
    static let all: [HabitTemplate] = [
        // Generale
        .toDo("general.read", "Leggere", "Read", symbol: "book", keywords: "libro lettura book reading"),
        .toDo("general.journal", "Scrivere il diario", "Write in your journal", symbol: "book.closed", keywords: "diario journal diary scrittura writing"),
        .toDo("general.language", "Studiare una lingua", "Learn a language", symbol: "character.book.closed", keywords: "inglese lingue studio english study"),
        .toDo("general.medicine", "Prendere le medicine", "Take your medicine", symbol: "pills", keywords: "farmaci pastiglie pills medication"),
        .toDo("general.teeth", "Lavarsi i denti", "Brush your teeth", symbol: "mouth", timesPerDay: 2, keywords: "denti spazzolino igiene teeth toothbrush hygiene"),
        .toDo("general.bed", "Andare a letto presto", "Go to bed early", symbol: "bed.double", keywords: "sonno dormire sleep night"),
        .toDo("general.family", "Chiamare la famiglia", "Call your family", symbol: "phone", schedule: .weekdays([1]), keywords: "telefonata genitori parenti phone parents"),
        .toDo("general.tidy", "Riordinare casa", "Tidy up the house", symbol: "house", keywords: "pulire ordine pulizie clean home"),
        .toDo("general.plants", "Annaffiare le piante", "Water the plants", symbol: "sprinkler.and.droplets", schedule: .weekdays([2, 5]), keywords: "fiori giardino flowers garden"),
        .toDo("general.yoga", "Fare yoga", "Do yoga", symbol: "figure.yoga", schedule: .timesPerWeek(3), keywords: "stretching allenamento workout"),

        // Salute
        .linked("health.walk", "Camminare", "Walk", symbol: "figure.walk", measure: .steps, goal: 8_000, keywords: "passi passeggiata steps"),
        .linked("health.run", "Correre", "Run", symbol: "figure.run", measure: .walkingRunningDistance, goal: 5_000, keywords: "corsa jogging running distanza km distance"),
        .linked("health.cycle", "Andare in bici", "Ride a bike", symbol: "bicycle", measure: .cyclingDistance, goal: 10_000, keywords: "bicicletta pedalare ciclismo cycling distanza km distance"),
        .linked("health.swim", "Nuotare", "Swim", symbol: "figure.pool.swim", measure: .swimmingDistance, goal: 1_000, keywords: "nuoto piscina vasche swimming pool laps"),
        .linked("health.workout", "Allenarsi", "Work out", symbol: "dumbbell", measure: .exerciseMinutes, goal: 30, keywords: "esercizio palestra allenamento sport exercise gym training minuti"),
        .linked("health.stand", "Stare in piedi", "Stand up", symbol: "figure.stand", measure: .standMinutes, goal: 60, keywords: "alzarsi postura minuti in piedi stand minutes posture"),
        .linked("health.stairs", "Salire le scale", "Take the stairs", symbol: "figure.stairs", measure: .flightsClimbed, goal: 10, keywords: "piani rampe gradini flights floors climb"),
        .linked("health.daylight", "Stare alla luce del giorno", "Spend time in daylight", symbol: "sun.max", measure: .timeInDaylight, goal: 30, keywords: "sole all'aperto fuori uscire luce sun outdoors outside light"),
        .linked("health.sleep", "Dormire abbastanza", "Get enough sleep", symbol: "bed.double", measure: .sleep, goal: 480, keywords: "sonno notte ore riposo sleep night hours rest"),
        .linked("health.rings", "Chiudere gli anelli", "Close your rings", symbol: "target", measure: .activityRings, goal: 3, keywords: "anelli attività movimento esercizio activity rings move exercise apple watch"),
        .linked("health.meditate", "Meditare", "Meditate", symbol: "figure.mind.and.body", measure: .mindfulMinutes, goal: 10, keywords: "meditazione consapevolezza mindfulness meditation"),
        .linked("health.breathe", "Respirare con calma", "Breathe slowly", symbol: "lungs", measure: .mindfulMinutes, goal: 5, keywords: "respiro respirazione consapevolezza breathing mindfulness"),

        // Alimentazione
        .linked("eating.water", "Bere acqua", "Drink water", .eating, symbol: "drop", measure: .water, goal: 2_000, keywords: "idratazione litri hydration"),
        .toDo("eating.vegetables", "Mangiare verdura", "Eat vegetables", .eating, symbol: "carrot", timesPerDay: 2, keywords: "verdure insalata veggies salad"),
        .toDo("eating.breakfast", "Fare colazione", "Have breakfast", .eating, symbol: "cup.and.saucer", keywords: "mattina pasto morning meal"),
        .toDo("eating.cook", "Cucinare a casa", "Cook at home", .eating, symbol: "frying.pan", keywords: "cucina pasto cooking meal"),
        .toDo("eating.fish", "Mangiare pesce", "Eat fish", .eating, symbol: "fish", schedule: .timesPerWeek(2), keywords: "omega pasto meal"),
        .toDo("eating.vitamins", "Prendere le vitamine", "Take your vitamins", .eating, symbol: "pill", keywords: "integratori supplements"),
        .toDo("eating.slowly", "Mangiare senza schermi", "Eat without screens", .eating, symbol: "fork.knife", keywords: "telefono tv pasto calma phone meal"),
        .toDo("eating.shopping", "Fare la spesa", "Go grocery shopping", .eating, symbol: "cart", schedule: .timesPerWeek(1), keywords: "supermercato spesa groceries supermarket"),
        .toDo("eating.weigh", "Pesarsi", "Weigh yourself", .eating, symbol: "scalemass", schedule: .weekdays([2]), keywords: "peso bilancia dieta weight scale diet"),

        // A tempo
        .timed("timed.read", "Leggere", "Read", symbol: "book", minutes: 20, keywords: "libro lettura book reading"),
        .timed("timed.meditate", "Meditare", "Meditate", symbol: "figure.mind.and.body", minutes: 10, keywords: "meditazione meditation"),
        .timed("timed.instrument", "Suonare uno strumento", "Play an instrument", symbol: "guitars", minutes: 30, keywords: "musica chitarra pianoforte music guitar piano practice"),
        .timed("timed.stretch", "Fare stretching", "Stretch", symbol: "figure.flexibility", minutes: 10, keywords: "allungamento flessibilità stretching flexibility"),
        .timed("timed.study", "Studiare", "Study", symbol: "books.vertical", minutes: 25, keywords: "studio compiti scuola homework school"),
        .timed("timed.write", "Scrivere", "Write", symbol: "pencil", minutes: 15, keywords: "scrittura diario writing journal"),
        .timed("timed.walk", "Fare una passeggiata", "Take a walk", symbol: "figure.walk", minutes: 30, keywords: "camminare camminata walking"),
        .timed("timed.clean", "Fare le pulizie", "Clean up", symbol: "bubbles.and.sparkles", minutes: 15, keywords: "pulire casa ordine cleaning house tidy"),
        .timed("timed.draw", "Disegnare", "Draw", symbol: "pencil.and.outline", minutes: 20, keywords: "disegno arte drawing art sketch"),

        // Da evitare
        .toAvoid("avoid.smoking", "Niente sigarette", "No cigarettes", symbol: "smoke", limit: 0, keywords: "fumo fumare smettere smoking smoke quit"),
        .toAvoid("avoid.coffee", "Meno caffè", "Less coffee", symbol: "mug", limit: 2, keywords: "caffeina tazza caffeine cup"),
        .toAvoid("avoid.sweets", "Niente dolci", "No sweets", symbol: "birthday.cake", limit: 0, keywords: "zucchero dolce torta sugar dessert cake candy"),
        .toAvoid("avoid.alcohol", "Meno alcol", "Less alcohol", symbol: "wineglass", limit: 1, keywords: "vino birra bere wine beer drink"),
        .toAvoid("avoid.phoneInBed", "Niente telefono a letto", "No phone in bed", symbol: "iphone.slash", limit: 0, keywords: "smartphone schermo notte screen night"),
        .toAvoid("avoid.social", "Niente social", "No social media", symbol: "apps.iphone", limit: 0, keywords: "instagram tiktok social network scroll"),
        .toAvoid("avoid.takeout", "Niente cibo da asporto", "No takeout", symbol: "takeoutbag.and.cup.and.straw", limit: 0, keywords: "fast food consegna delivery"),
        .toAvoid("avoid.spending", "Niente spese inutili", "No impulse buys", symbol: "cart.badge.minus", limit: 0, keywords: "acquisti soldi shopping risparmio money saving"),
        .toAvoid("avoid.snacks", "Niente snack", "No snacks", symbol: "popcorn", limit: 0, keywords: "spuntini merendine fuori pasto snacking"),
    ]
}
