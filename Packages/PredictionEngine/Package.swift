// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PredictionEngine",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "PredictionEngine", targets: ["PredictionEngine"])
    ],
    dependencies: [
        .package(path: "../SharedModels")
    ],
    targets: [
        .target(
            name: "PredictionEngine",
            dependencies: ["SharedModels"]
        ),
        .testTarget(name: "PredictionEngineTests", dependencies: ["PredictionEngine"])
    ]
)
