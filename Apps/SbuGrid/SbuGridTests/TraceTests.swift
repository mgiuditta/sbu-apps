import AVFoundation
import Foundation
import Testing
@testable import SbuGrid

struct TraceTests {
    @Test(arguments: [
        (AVAuthorizationStatus.authorized, true, CameraAccess.allowed),
        (.notDetermined, true, .notDetermined),
        (.denied, true, .denied),
        (.restricted, true, .denied),
        (.authorized, false, .unavailable),
        (.notDetermined, false, .unavailable),
        (.denied, false, .unavailable),
    ])
    func accessFollowsTheAuthorizationAndTheCamera(status: AVAuthorizationStatus, hasCamera: Bool, expected: CameraAccess) {
        #expect(CameraAccess.from(status, hasCamera: hasCamera) == expected)
    }

    @Test(arguments: [
        ("notDetermined", CameraAccess?.some(.notDetermined)),
        ("denied", .some(.denied)),
        ("unavailable", .some(.unavailable)),
        ("allowed", nil),
        ("", nil),
    ])
    func uiTestsCanForceAnAccess(value: String, expected: CameraAccess?) throws {
        let defaults = try #require(UserDefaults(suiteName: "TraceTests-\(UUID().uuidString)"))
        defaults.set(value, forKey: "CAMERA_ACCESS")
        #expect(CameraAccess.forced(by: defaults) == expected)
    }

    @Test func nothingForcedReadsTheRealAccess() throws {
        let defaults = try #require(UserDefaults(suiteName: "TraceTests-\(UUID().uuidString)"))
        #expect(CameraAccess.forced(by: defaults) == nil)
    }

    @Test func aForcedAccessStaysAfterRunningAndRefreshing() async {
        let camera = TraceCamera(forcedAccess: .denied)
        #expect(camera.access == .denied)
        await camera.run()
        camera.refresh()
        #expect(camera.access == .denied)
        #expect(camera.isRunning == false)
    }

    @Test func thePhotoStartsHalfSeeThrough() {
        #expect(TraceSettings().photoOpacity == 0.5)
    }

    @Test(arguments: [(-1.0, 0.05), (0.0, 0.05), (0.05, 0.05), (0.3, 0.3), (0.95, 0.95), (1.0, 0.95), (Double.nan, 0.05), (Double.infinity, 0.95)])
    func thePhotoIsNeverFullyClearNorSolid(value: Double, expected: Double) {
        var trace = TraceSettings()
        trace.photoOpacity = value
        #expect(trace.photoOpacity == expected)
    }

    @Test func roundTripsAndClampsWhenDecoded() throws {
        var trace = TraceSettings()
        trace.photoOpacity = 0.35
        #expect(try JSONDecoder().decode(TraceSettings.self, from: JSONEncoder().encode(trace)) == trace)
        let absurd = try JSONDecoder().decode(TraceSettings.self, from: Data(#"{"photoOpacity": 7}"#.utf8))
        #expect(absurd.photoOpacity == 0.95)
        let missing = try JSONDecoder().decode(TraceSettings.self, from: Data("{}".utf8))
        #expect(missing.photoOpacity == 0.5)
    }

    @Test func theOpacityIsKeptAcrossLaunches() throws {
        let defaults = try #require(UserDefaults(suiteName: "TraceTests-\(UUID().uuidString)"))
        let model = GridModel(photoStore: nil, stateStore: StateStore(defaults: defaults))
        model.trace.photoOpacity = 0.7
        #expect(GridModel(photoStore: nil, stateStore: StateStore(defaults: defaults)).trace.photoOpacity == 0.7)
    }

    @Test func anOlderStateWithoutTracingStillLoads() throws {
        let state = try JSONDecoder().decode(GridState.self, from: Data(#"{"settings": {"columns": 5}}"#.utf8))
        #expect(state.trace == TraceSettings())
        #expect(state.settings.columns == 5)
    }
}
