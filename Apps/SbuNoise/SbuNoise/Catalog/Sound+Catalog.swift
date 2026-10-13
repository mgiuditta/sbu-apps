import Foundation

extension Sound {
    /// Every sound of Sbu Noise, group by group, in the player's default order. The loops are made
    /// by `SoundTools/make_sounds.py` from `SoundTools/sounds.json`, which lists the same ids and,
    /// for each recording, its CC0 source.
    nonisolated static let catalog: [Sound] = generated + [
        // Pioggia
        Sound(id: "rain.heavy", name: "Pioggia forte", systemImage: "cloud.heavyrain", category: .rain, source: .loop("rain.heavy", credit: SoundCredit(title: "rain heavy porch full steady.flac", author: "kyles", page: "https://freesound.org/people/kyles/sounds/454128/"))),
        Sound(id: "rain.roof", name: "Pioggia sul tetto", systemImage: "house", category: .rain, source: .loop("rain.roof", credit: SoundCredit(title: "Rain on the House Roof Window #001", author: "bassimat", page: "https://freesound.org/people/bassimat/sounds/833924/"))),
        Sound(id: "rain.light", name: "Pioggia leggera", systemImage: "cloud.drizzle", category: .rain, source: .loop("rain.light", credit: SoundCredit(title: "gentle steady spring rain city", author: "Garuda1982", page: "https://freesound.org/people/Garuda1982/sounds/852917/"))),
        Sound(id: "rain.storm", name: "Temporale", systemImage: "cloud.bolt.rain", category: .rain, source: .loop("rain.storm", credit: SoundCredit(title: "20260531 Raining in Bangkok 01", author: "kijjaz", page: "https://freesound.org/people/kijjaz/sounds/856405/"))),
        Sound(id: "rain.car", name: "Pioggia sull'auto", systemImage: "car", category: .rain, source: .loop("rain.car", credit: SoundCredit(title: "Rain on the roof of car inside 5", author: "Cinetony", page: "https://freesound.org/people/Cinetony/sounds/672703/"))),
        Sound(id: "rain.tent", name: "Pioggia sulla tenda", systemImage: "tent", category: .rain, source: .loop("rain.tent", credit: SoundCredit(title: "230702 Rain on fabric tent, like electrical static, 3 variations, R-07 EM272s, Stratford 1pm", author: "TRP", page: "https://freesound.org/people/TRP/sounds/717863/"))),
        // Acqua
        Sound(id: "water.ocean", name: "Mare", systemImage: "water.waves", category: .water, source: .loop("water.ocean", credit: SoundCredit(title: "Ocean-waves-binaural.WAV", author: "L.Finck", page: "https://freesound.org/people/L.Finck/sounds/636552/"))),
        Sound(id: "water.surf", name: "Onde", systemImage: "beach.umbrella", category: .water, source: .loop("water.surf", credit: SoundCredit(title: "Ocean waves white noisy BAHAMAS 180520.wav", author: "TRP", page: "https://freesound.org/people/TRP/sounds/573179/"))),
        Sound(id: "water.stream", name: "Ruscello", systemImage: "drop.triangle", category: .water, source: .loop("water.stream", credit: SoundCredit(title: "stream2.wav", author: "gluckose", page: "https://freesound.org/people/gluckose/sounds/333987/"))),
        Sound(id: "water.river", name: "Fiume", systemImage: "water.waves.and.arrow.down", category: .water, source: .loop("water.river", credit: SoundCredit(title: "Saliouse river murmur 1", author: "bruno.auzet", page: "https://freesound.org/people/bruno.auzet/sounds/730154/"))),
        Sound(id: "water.waterfall", name: "Cascata", systemImage: "mountain.2", category: .water, source: .loop("water.waterfall", credit: SoundCredit(title: "Hidden waterfall.WAV", author: "BassmanJourney", page: "https://freesound.org/people/BassmanJourney/sounds/632107/"))),
        Sound(id: "water.drops", name: "Gocce", systemImage: "drop", category: .water, source: .loop("water.drops", credit: nil)),
        // Natura
        Sound(id: "nature.wind", name: "Vento", systemImage: "wind", category: .nature, source: .loop("nature.wind", credit: nil)),
        Sound(id: "nature.pines", name: "Vento tra i pini", systemImage: "tree", category: .nature, source: .loop("nature.pines", credit: SoundCredit(title: "Silencyo_CC_Wind Mistral_Medium_pine trees_leaves_foliage.aif", author: "silencyo", page: "https://freesound.org/people/silencyo/sounds/81792/"))),
        Sound(id: "nature.fire", name: "Fuoco", systemImage: "flame", category: .nature, source: .loop("nature.fire", credit: SoundCredit(title: "Fireplace.wav", author: "inchadney", page: "https://freesound.org/people/inchadney/sounds/132534/"))),
        Sound(id: "nature.night", name: "Notte", systemImage: "moon.stars", category: .nature, source: .loop("nature.night", credit: SoundCredit(title: "Crickets during the night, close to the beach in Mexico", author: "felix.blume", page: "https://freesound.org/people/felix.blume/sounds/479041/"))),
        Sound(id: "nature.frogs", name: "Rane", systemImage: "lizard", category: .nature, source: .loop("nature.frogs", credit: SoundCredit(title: "Frogs at Night - Lots of Them.wav", author: "Traviow", page: "https://freesound.org/people/Traviow/sounds/687212/"))),
        Sound(id: "nature.forest", name: "Bosco", systemImage: "bird", category: .nature, source: .loop("nature.forest", credit: SoundCredit(title: "Morning Forest with Birds", author: "RyanKingArt", page: "https://freesound.org/people/RyanKingArt/sounds/844605/"))),
        // Casa
        Sound(id: "home.fan", name: "Ventilatore", systemImage: "fan", category: .home, source: .loop("home.fan", credit: SoundCredit(title: "Large Floor Fan - Steady Deep Hum - 2 Minutes", author: "FansAreCoolAndRelaxing16", page: "https://freesound.org/people/FansAreCoolAndRelaxing16/sounds/843484/"))),
        Sound(id: "home.aircon", name: "Condizionatore", systemImage: "air.conditioner.horizontal", category: .home, source: .loop("home.aircon", credit: nil)),
        Sound(id: "home.dryer", name: "Asciugatrice", systemImage: "dryer", category: .home, source: .loop("home.dryer", credit: SoundCredit(title: "Dryer", author: "Dinsfire", page: "https://freesound.org/people/Dinsfire/sounds/169625/"))),
        Sound(id: "home.washer", name: "Lavatrice", systemImage: "washer", category: .home, source: .loop("home.washer", credit: SoundCredit(title: "washing machine spin cycle 2.wav", author: "greatsoundstube", page: "https://freesound.org/people/greatsoundstube/sounds/631894/"))),
        Sound(id: "home.dishwasher", name: "Lavastoviglie", systemImage: "dishwasher", category: .home, source: .loop("home.dishwasher", credit: SoundCredit(title: "Dishwasher", author: "one_moment", page: "https://freesound.org/people/one_moment/sounds/850044/"))),
        Sound(id: "home.cat", name: "Fusa del gatto", systemImage: "cat", category: .home, source: .loop("home.cat", credit: SoundCredit(title: "Elderly female cat purrr (minette)", author: "Sadiquecat", page: "https://freesound.org/people/Sadiquecat/sounds/855881/"))),
        Sound(id: "home.clock", name: "Orologio", systemImage: "clock", category: .home, source: .loop("home.clock", credit: SoundCredit(title: "Clock Ticking.wav", author: "photogtony", page: "https://freesound.org/people/photogtony/sounds/242008/"))),
        // Viaggio
        Sound(id: "travel.train", name: "Treno", systemImage: "tram", category: .travel, source: .loop("travel.train", credit: SoundCredit(title: "train", author: "organicmanpl", page: "https://freesound.org/people/organicmanpl/sounds/464048/"))),
        Sound(id: "travel.plane", name: "Aereo", systemImage: "airplane", category: .travel, source: .loop("travel.plane", credit: nil)),
        Sound(id: "travel.car", name: "Auto", systemImage: "car.side", category: .travel, source: .loop("travel.car", credit: SoundCredit(title: "Car Driving Interior", author: "squareal", page: "https://freesound.org/people/squareal/sounds/237374/"))),
        Sound(id: "travel.city", name: "Città", systemImage: "building.2", category: .travel, source: .loop("travel.city", credit: SoundCredit(title: "Ciudad de Mexico DF Colonia Roma Busy Street traffic urban city ambience Ed Larez VSNR", author: "visionear", page: "https://freesound.org/people/visionear/sounds/723607/"))),
    ]
}
