// Writes the Vision feature prints (revision 2) of the test fixtures to a JSON file.
//
// The iOS simulator cannot run Vision's neural networks (no Neural Engine, no Metal context),
// so the unit tests read the prints this script computes on the Mac, with the same model.
//
//     swift Fixtures/vision_prints.swift SbuCleanTests/Fixtures SbuCleanTests/Fixtures/vision-prints.json

import Foundation
import Vision

let arguments = CommandLine.arguments
guard arguments.count == 3 else {
    print("usage: vision_prints.swift FIXTURE_DIR OUTPUT_JSON")
    exit(1)
}

let folder = URL(fileURLWithPath: arguments[1])
let names = try FileManager.default.contentsOfDirectory(atPath: folder.path).filter { $0.hasSuffix(".jpg") }.sorted()
var prints: [String: [Float]] = [:]
for name in names {
    let request = VNGenerateImageFeaturePrintRequest()
    request.revision = VNGenerateImageFeaturePrintRequestRevision2
    request.imageCropAndScaleOption = .scaleFill
    try VNImageRequestHandler(url: folder.appendingPathComponent(name)).perform([request])
    guard let observation = request.results?.first else { continue }

    prints[(name as NSString).deletingPathExtension] = observation.data.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }
}
let encoder = JSONEncoder()
encoder.outputFormatting = .sortedKeys
try encoder.encode(prints).write(to: URL(fileURLWithPath: arguments[2]))
print("wrote \(prints.count) prints")
