import CoreGraphics
import Foundation
import Testing
@testable import SbuGrid

struct GridModelTests {
    let directory = URL.temporaryDirectory.appending(path: "GridModelTests-\(UUID().uuidString)", directoryHint: .isDirectory)
    let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "GridModelTests-\(UUID().uuidString)"))
    }

    private func makeModel() -> GridModel {
        GridModel(photoStore: PhotoStore(directory: directory), stateStore: StateStore(defaults: defaults))
    }

    @Test func startsWithoutAPhoto() {
        let model = makeModel()
        #expect(model.photo == nil)
        #expect(model.pictureSize == .zero)
        #expect(model.count == GridCount(columns: 0, rows: 0))
        #expect(model.isOpening == false)
        #expect(model.openError == nil)
    }

    @Test func opensAPhotoAndKeepsIt() async throws {
        let model = makeModel()
        let before = model.photoID
        await model.open(TestImage.data(width: 1200, height: 1600))
        #expect(model.photo?.width == 1200)
        #expect(model.photoID != before)
        #expect(model.isOpening == false)
        #expect(model.openError == nil)
        // Default grid: 4 square columns of 300 pixels, 1600 / 300 = 6 rows.
        #expect(model.count == GridCount(columns: 4, rows: 6))

        let relaunched = makeModel()
        #expect(relaunched.photo?.width == 1200)
    }

    @Test func noDataSaysThePhotoDidNotArrive() async {
        let model = makeModel()
        await model.open(nil)
        #expect(model.openError == .unavailable)
        #expect(model.isShowingOpenError)
        #expect(model.photo == nil)
    }

    @Test func dataThatIsNotAPhotoSaysSoAndKeepsThePreviousPhoto() async {
        let model = makeModel()
        await model.open(TestImage.data(width: 100, height: 100))
        let id = model.photoID
        await model.open(Data("nope".utf8))
        #expect(model.openError == .unreadable)
        #expect(model.photo?.width == 100)
        #expect(model.photoID == id)
    }

    @Test func dismissingTheAlertForgetsTheError() async {
        let model = makeModel()
        await model.open(nil)
        model.isShowingOpenError = false
        #expect(model.openError == nil)
        // Setting it to true does not invent an error.
        model.isShowingOpenError = true
        #expect(model.openError == nil)
    }

    @Test func choicesAreKeptAcrossLaunches() {
        let model = makeModel()
        model.settings.columns = 9
        model.settings.hasSquareCells = false
        model.settings.rows = 3
        let relaunched = makeModel()
        #expect(relaunched.settings.columns == 9)
        #expect(relaunched.settings.rows == 3)
        #expect(relaunched.cellRule == .divide(columns: 9, rows: 3))
    }

    @Test func squareCellsCountRowsFromThePhotoShape() {
        let model = GridModel(photoStore: nil, stateStore: nil, photo: TestImage.make(width: 1600, height: 900))
        model.settings.columns = 8
        #expect(model.count == GridCount(columns: 8, rows: 5))
        model.settings.hasSquareCells = false
        model.settings.rows = 2
        #expect(model.count == GridCount(columns: 8, rows: 2))
    }

    @Test func showingAPhotoStartsZoomOver() {
        let model = GridModel(photoStore: nil, stateStore: nil)
        model.show(TestImage.make(width: 10, height: 10))
        let first = model.photoID
        model.show(TestImage.make(width: 10, height: 10))
        #expect(model.photoID != first)
    }

    @Test func aModelWithoutStoresKeepsNothing() async {
        let model = GridModel(photoStore: nil, stateStore: nil)
        model.settings.columns = 30
        await model.open(TestImage.data(width: 10, height: 10))
        #expect(GridModel(photoStore: nil, stateStore: nil).settings.columns == GridSettings().columns)
        #expect(GridModel(photoStore: nil, stateStore: nil).photo == nil)
    }

    @Test(arguments: [
        (["GRID_PHOTO": "demo"], LaunchScenario.demo),
        (["GRID_PHOTO": "none"], .empty),
        (["GRID_PHOTO": "other"], .user),
        (["FASTLANE_SNAPSHOT": "YES"], .demo),
        (["FASTLANE_SNAPSHOT": "YES", "GRID_PHOTO": "none"], .empty),
        ([:], .user),
    ])
    func launchArgumentsPickTheScenario(values: [String: String], expected: LaunchScenario) throws {
        let defaults = try #require(UserDefaults(suiteName: "Launch-\(UUID().uuidString)"))
        for (key, value) in values {
            defaults.set(value, forKey: key)
        }
        #expect(LaunchScenario(defaults: defaults) == expected)
    }

    @Test func theDemoStartsOnTheStillLife() {
        let model = GridModel.forLaunch(.demo)
        #expect(model.photo?.width == Int(DemoPhoto.size.width))
        #expect(model.photo?.height == Int(DemoPhoto.size.height))
        #expect(GridModel.forLaunch(.empty).photo == nil)
    }
}
