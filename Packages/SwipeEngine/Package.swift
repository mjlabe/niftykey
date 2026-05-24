// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwipeEngine",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "SwipeEngine", targets: ["SwipeEngine"])
    ],
    dependencies: [
        .package(path: "../SharedModels"),
        .package(path: "../PredictionEngine")
    ],
    targets: [
        .target(name: "SwipeEngine", dependencies: ["SharedModels", "PredictionEngine"]),
        .testTarget(name: "SwipeEngineTests", dependencies: ["SwipeEngine"])
    ]
)
