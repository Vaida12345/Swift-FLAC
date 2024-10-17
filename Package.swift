// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-FLAC",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "swiftFLAC",
            targets: ["swiftFLAC"]
        ),
    ],
    targets: [
        .target(
            name: "swiftFLAC",
            path: "swift-FLAC"
        ),
        .executableTarget(
            name: "Client",
            path: "Client"
        ),
        .testTarget(
            name: "Tests",
            dependencies: ["swiftFLAC"],
            path: "Tests"
        )
    ]
)
