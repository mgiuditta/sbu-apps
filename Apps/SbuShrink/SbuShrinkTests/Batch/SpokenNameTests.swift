import Testing
@testable import SbuShrink

struct SpokenNameTests {
    @Test(arguments: [
        ("IMG_1669.MOV", "IMG 1669"),
        ("my-trip_2024.mp4", "my trip 2024"),
        ("Vacanze al mare.m4v", "Vacanze al mare"),
        ("__.mov", "__.mov"),
        ("", ""),
        ("no extension", "no extension"),
        ("a__b--c.mov", "a b c"),
    ])
    func fileNamesReadAsWords(name: String, expected: String) {
        #expect(VideoJob(assetID: nil, name: name).spokenName == expected)
    }
}
