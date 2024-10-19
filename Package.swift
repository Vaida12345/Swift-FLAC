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
            dependencies: ["DetailedDescription", "BitwiseOperators"],
            path: "Swift-FLAC"
        ),
        .target(
            name: "SwiftAIFF",
            dependencies: ["DetailedDescription", "BitwiseOperators"],
            path: "Swift-AIFF"
        ),
        .target(
            name: "BitwiseOperators",
            path: "Bitwise Operators"
        ),
        .executableTarget(
            name: "Client",
            dependencies: ["SwiftFLAC", "DetailedDescription", "SwiftAIFF"],
            path: "Client"
        ),
        .testTarget(
            name: "Tests",
            dependencies: ["SwiftFLAC", "SwiftAIFF", "BitwiseOperators"],
            path: "Tests"
        )
    ]
)
