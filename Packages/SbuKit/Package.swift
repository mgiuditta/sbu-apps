// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SbuKit",
    defaultLocalization: "it",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SbuKit", targets: ["SbuKit"]),
    ],
    targets: [
        .target(
            name: "SbuKit",
            resources: [.process("Resources")],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(
            name: "SbuKitTests",
            dependencies: ["SbuKit"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
    ]
)
