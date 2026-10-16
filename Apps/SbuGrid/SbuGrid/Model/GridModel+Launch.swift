import Foundation

extension GridModel {
    /// The model for a launch: the user's own, or a clean one for tests that keeps nothing.
    static func forLaunch(_ scenario: LaunchScenario = LaunchScenario(defaults: .standard)) -> GridModel {
        switch scenario {
        case .user:
            GridModel()
        case .demo:
            GridModel(photoStore: nil, stateStore: nil, photo: DemoPhoto.stillLife())
        case .empty:
            GridModel(photoStore: nil, stateStore: nil)
        }
    }
}
