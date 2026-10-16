import CoreGraphics
import Foundation
import Testing
@testable import SbuGrid

/// The sheet, the crop and the export on the model.
struct GridModelPaperTests {
    let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "GridModelPaperTests-\(UUID().uuidString)"))
    }

    private func makeModel(photo: CGImage? = TestImage.make(width: 1200, height: 1600)) -> GridModel {
        let model = GridModel(photoStore: nil, stateStore: StateStore(defaults: defaults), photo: photo)
        model.paper = PaperSettings(locale: Locale(identifier: "it_IT"))
        return model
    }

    @Test func withoutASheetThePictureIsTheWholePhoto() {
        let model = makeModel()
        #expect(model.crop == nil)
        #expect(model.pictureSize == CGSize(width: 1200, height: 1600))
        #expect(model.cellRule == model.settings.cellRule)
    }

    @Test func aSheetCropsThePhotoToItsShape() {
        let model = makeModel()
        model.paper.format = .a4
        #expect(model.crop != nil)
        let size = model.pictureSize
        // A4 is narrower than 3:4: full height, 1600 × 0.707 = 1131 pixels across.
        #expect(size.height == 1600)
        #expect(abs(size.width - 1131) <= 1)
        #expect(model.cellRule == .physical(cellLength: 2, paperWidth: 21))
        // 2 cm cells on A4: 11 columns, 15 rows.
        #expect(model.count == GridCount(columns: 11, rows: 15))
    }

    @Test func turningTheSheetCropsAgain() {
        let model = makeModel()
        model.paper.format = .a4
        model.paper.orientation = .landscape
        #expect(model.pictureSize.width == 1200)
        #expect(abs(model.pictureSize.height - 849) <= 1)
        #expect(model.count == GridCount(columns: 15, rows: 11))
    }

    @Test func aBiggerCellMeansFewerRowsAndColumns() {
        let model = makeModel()
        model.paper.format = .a4
        let id = model.pictureID
        model.paper.cellLength = 3
        #expect(model.count == GridCount(columns: 7, rows: 10))
        // Same shape: the crop is kept.
        #expect(model.pictureID == id)
    }

    @Test func aHandMadeCropIsKeptAndSaved() throws {
        let model = makeModel()
        model.setCrop(CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5))
        #expect(model.pictureSize == CGSize(width: 600, height: 800))
        let saved = StateStore(defaults: defaults).load()
        #expect(saved.crop == CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5))
        let relaunched = GridModel(photoStore: nil, stateStore: StateStore(defaults: defaults), photo: TestImage.make(width: 1200, height: 1600))
        #expect(relaunched.pictureSize == CGSize(width: 600, height: 800))
    }

    @Test func anAbsurdCropShowsTheWholePhoto() {
        let model = makeModel()
        model.setCrop(CGRect(x: 0.9, y: 0.9, width: 0.5, height: 0.5))
        #expect(model.crop == nil)
        #expect(model.pictureSize == CGSize(width: 1200, height: 1600))
    }

    @Test func aNewPhotoIsCroppedToTheSheetAtOnce() {
        let model = makeModel()
        model.paper.format = .a4
        model.show(TestImage.make(width: 3000, height: 1000))
        #expect(model.pictureSize.height == 1000)
        #expect(abs(model.pictureSize.width - 707) <= 1)
    }

    @Test func aNewPhotoWithoutASheetIsWhole() {
        let model = makeModel()
        model.setCrop(CGRect(x: 0, y: 0, width: 0.5, height: 0.5))
        model.show(TestImage.make(width: 300, height: 100))
        #expect(model.crop == nil)
        #expect(model.pictureSize == CGSize(width: 300, height: 100))
    }

    @Test func goingBackToNoSheetKeepsTheCropAndUsesTheGridSettings() {
        let model = makeModel()
        model.paper.format = .a4
        let crop = model.crop
        model.paper.format = .free
        #expect(model.crop == crop)
        #expect(model.cellRule == model.settings.cellRule)
    }

    @Test func theSheetIsKeptAcrossLaunches() {
        let model = makeModel()
        model.paper.format = .a3
        model.paper.orientation = .landscape
        model.paper.cellLength = 4
        let relaunched = GridModel(photoStore: nil, stateStore: StateStore(defaults: defaults))
        #expect(relaunched.paper.format == .a3)
        #expect(relaunched.paper.orientation == .landscape)
        #expect(relaunched.paper.cellLength == 4)
    }

    @Test func aSheetWithoutAPhotoCropsNothingYet() {
        let model = makeModel(photo: nil)
        model.paper.format = .a4
        #expect(model.picture == nil)
        #expect(model.pictureSize == .zero)
        #expect(model.count == GridCount(columns: 0, rows: 0))
    }

    @Test func aStateWithADamagedCropLoadsWithoutIt() throws {
        let json = #"{"crop": [[0.9, 0.9], [0.5, 0.5]], "settings": {"columns": 7}}"#
        let state = try JSONDecoder().decode(GridState.self, from: Data(json.utf8))
        #expect(state.crop == nil)
        #expect(state.settings.columns == 7)
    }

    @Test func aStateRoundTrips() throws {
        var paper = PaperSettings(locale: Locale(identifier: "it_IT"))
        paper.format = .letter
        let state = GridState(settings: GridSettings(), paper: paper, crop: CGRect(x: 0.1, y: 0.1, width: 0.5, height: 0.5))
        #expect(try JSONDecoder().decode(GridState.self, from: JSONEncoder().encode(state)) == state)
    }
}
