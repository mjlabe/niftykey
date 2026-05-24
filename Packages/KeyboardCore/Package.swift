// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KeyboardCore",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "KeyboardCore", targets: ["KeyboardCore"])
    ],
    dependencies: [
        .package(path: "../SharedModels")
    ],
    targets: [
        .target(name: "KeyboardCore", dependencies: ["SharedModels"]),
        .testTarget(name: "KeyboardCoreTests", dependencies: ["KeyboardCore"])
    ]
)
