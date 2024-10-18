// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swift-FLAC",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "SwiftFLAC",
            targets: ["SwiftFLAC"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Vaida12345/DetailedDescription.git", branch: "main")
    ],
    targets: [
        .target(
            name: "SwiftFLAC",
            dependencies: ["DetailedDescription"],
            path: "Swift-FLAC"
        ),
        .executableTarget(
            name: "Client",
            dependencies: ["SwiftFLAC", "DetailedDescription"],
            path: "Client"
        ),
        .testTarget(
            name: "Tests",
            dependencies: ["SwiftFLAC"],
            path: "Tests"
        )
    ]
)
