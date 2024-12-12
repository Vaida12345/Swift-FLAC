// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swift-FLAC",
    products: [
        .library(
            name: "SwiftFLAC",
            targets: ["SwiftFLAC"]
        ),
    ],
    dependencies: [
        .package(url: "https://www.github.com/Vaida12345/DetailedDescription", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftFLAC",
            dependencies: ["DetailedDescription", "BitwiseOperators", "SwiftAIFF"],
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
