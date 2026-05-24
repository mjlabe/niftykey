// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ThemeEngine",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "ThemeEngine", targets: ["ThemeEngine"])
    ],
    targets: [
        .target(name: "ThemeEngine"),
        .testTarget(name: "ThemeEngineTests", dependencies: ["ThemeEngine"])
    ]
)
