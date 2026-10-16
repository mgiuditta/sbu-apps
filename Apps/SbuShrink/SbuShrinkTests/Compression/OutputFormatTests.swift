import AVFoundation
import Testing
@testable import SbuShrink

struct OutputFormatTests {
    @Test(arguments: [
        ("mov", false, OutputFormat.mov),
        ("MOV", false, .mov),
        ("mp4", false, .mp4),
        ("M4V", false, .mp4),
        ("m4v", false, .mp4),
        ("", false, .mov),
        ("avi", false, .mov),
        ("mov", true, .mp4),
        ("", true, .mp4),
        ("mp4", true, .mp4),
    ])
    func containerFollowsTheSourceUnlessMP4IsAsked(ext: String, convertsToMP4: Bool, expected: OutputFormat) {
        #expect(OutputFormat(sourceExtension: ext, convertsToMP4: convertsToMP4) == expected)
    }

    @Test func fileTypesAndExtensionsMatch() {
        #expect(OutputFormat.mov.fileType == .mov)
        #expect(OutputFormat.mp4.fileType == .mp4)
        #expect(OutputFormat.mov.fileExtension == "mov")
        #expect(OutputFormat.mp4.fileExtension == "mp4")
        #expect(OutputFormat.mov.contentType == .quickTimeMovie)
        #expect(OutputFormat.mp4.contentType == .mpeg4Movie)
    }
}
