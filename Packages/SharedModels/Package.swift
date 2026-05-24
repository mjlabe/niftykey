// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SharedModels",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "SharedModels", targets: ["SharedModels"])
    ],
    targets: [
        .target(name: "SharedModels"),
        .testTarget(name: "SharedModelsTests", dependencies: ["SharedModels"])
    ]
)
